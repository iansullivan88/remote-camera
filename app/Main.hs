{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}

module Main where

import Web.Scotty
import Data.Foldable
import Data.Aeson hiding(json)
import System.Directory
import Data.Maybe
import System.IO
import Network.Wai.Middleware.Static
import System.FilePath
import System.Process
import GHC.Generics
import GHC.IO.Handle
import Control.Concurrent.MVar
import Control.Monad
import Control.Monad.IO.Class(liftIO)
import Control.Concurrent
import qualified Control.Monad.State.Lazy as S
import qualified Data.ByteString.Lazy as B

type ProcessStateAction = S.StateT ProcessState IO ()
type ProcessState = Maybe (ProcessHandle, Handle)

data Config = Config {
    staticWebsiteDirectory :: String,
    videoStreamDirectory :: String,
    streamServerCommand :: String,
    port :: Int
} deriving Generic

instance FromJSON Config where
    parseJSON = genericParseJSON defaultOptions

data WebResponse = WebResponse {
    success :: Bool
} deriving Generic

instance ToJSON WebResponse where
    toJSON     = genericToJSON defaultOptions
    toEncoding = genericToEncoding defaultOptions

main :: IO ()
main = do
    config <- fmap (fromJust . decode) (B.readFile "config.json") :: IO Config
    let staticDirectory = staticWebsiteDirectory config
        streamDirectory = videoStreamDirectory config
        streamCommand   = streamServerCommand config
    var <- newMVar Nothing
    cleanVideoFiles streamDirectory
    scotty (port config) $ do
        post "/api/start" $ liftIO (handleProcessStartStop var (startProcess streamDirectory streamCommand)) >>= json
        post "/api/stop"  $ liftIO (handleProcessStartStop var (stopProcess streamDirectory))  >>= json
        middleware $ staticPolicy (hasPrefix "video/" >-> policy (Just . drop 6) >-> addBase streamDirectory)
        middleware $ staticPolicy (only [("", staticDirectory </> "index.html")] <|> addBase staticDirectory)

handleProcessStartStop :: MVar ProcessState -> ProcessStateAction -> IO WebResponse
handleProcessStartStop var action = do
    isBusy <- isEmptyMVar var
    if isBusy then return $ WebResponse False
    else do
        modifyMVar_ var (S.execStateT action)
        return $ WebResponse True

startProcess :: FilePath -> FilePath -> ProcessStateAction
startProcess streamPath scriptPath = do
    currentState <- S.get
    case currentState of
        Just _  -> return ()
        Nothing -> do
            handle <- liftIO $ spawnProcessWithInput scriptPath [streamPath]
            -- give video 15s to start capturing
            liftIO $ threadDelay 15000000
            S.put (Just handle)
            where
                spawnProcessWithInput cmd args = do
                    (Just stdin,_,_,p) <- createProcess_ "videoStreamer" ((proc cmd args) { std_in = CreatePipe })
                    return (p, stdin)

stopProcess :: FilePath -> ProcessStateAction
stopProcess streamPath = do
    currentState <- S.get
    case currentState of
        Nothing         -> return ()
        Just (p, stdin) -> do
            liftIO $ do
                isRunning <- hIsOpen stdin
                when isRunning $ do
                    hPutStrLn stdin "x" -- x is the signal to stop processing
                    hClose stdin
                    waitForProcess p
                    cleanVideoFiles streamPath
            S.put Nothing

cleanVideoFiles :: FilePath -> IO ()
cleanVideoFiles dir = do
    files <- listDirectory dir
    traverse_ removeFile
        $ map (dir </>)
        $ filter (\f -> let e = takeExtension f in e == ".ts" || e == ".m3u8") files
