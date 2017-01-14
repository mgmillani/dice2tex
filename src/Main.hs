--  Copyright 2017 Marcelo Garlet Millani
--  This file is part of dice2tex.

--  dice2tex is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

--  dice2tex is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.

--  You should have received a copy of the GNU General Public License
--  along with dice2tex.  If not, see <http://www.gnu.org/licenses/>.

module Main where

import Data.List
import System.Environment

data Action =
  Action
  { nColumns :: Int
  , inFl  :: FilePath
  , outFl :: FilePath
  , help  :: Bool
  }

defaultAction = Action{nColumns = 4, inFl = "", outFl = "", help = False}

appname = "dice2tex"
appversion = "0.1.0.0"

breaks :: [a] -> Int -> [[a]]
breaks [] _ = []
breaks xs n = (take n xs) : (breaks (drop n xs) n)

latexify page columns pref =
  concat
  [ "\\setcounter{dice}{", pageNum ,"}\n"
  , "\\begin{table}[bp]\n\\centering\n\\begin{tabular}{", concat $ take columns $ repeat "r l|", "}\n"
  , texpage cls pref
  , "\\end{tabular}\n\\end{table}\n"
  , "\\clearpage\n"
  ]
  where
    n = ceiling $ (fromIntegral $ length page) / (fromIntegral columns)
    cls = breaks page n
    pageNum = take pref $ fst $ head $ head cls

texpage :: [[(String, String)]] -> Int -> String
texpage [] _ = []
texpage cls pref
  | and $ map null cls = []
  | otherwise =
    texline (map mhead cls) pref ++ texpage (map mtail cls) pref
    where
      mhead [] = ("", "")
      mhead (x:xs) = x
      mtail [] = []
      mtail (x:xs) = xs

texcell :: Int -> (String, String) -> String
texcell pref ("",_) = "&"
texcell pref (pos,word) =
  concat ["& ", texpos $ drop pref pos, ": &", "\\textbf{", tail word, "} "]
  where
    texpos pos = if and $ map (=='1') (tail pos) then "\\underline{" ++ pos ++ "}"  else (" " ++ tail pos)

texline :: [(String, String)] -> Int -> String
texline ln pref =
  (tail $ concatMap (texcell pref) ln) ++ "\\\\\n"

parseArgs action [] = action
parseArgs action args = case args of
  "-c":columns:r        -> parseArgs action{nColumns = read columns} r
  "--columns":columns:r -> parseArgs action{nColumns = read columns} r
  "-h":r     -> parseArgs action{help = True} r
  "--help":r -> parseArgs action{help = True} r
  "-o":fl:r       -> parseArgs action{outFl = fl} r
  "--output":fl:r -> parseArgs action{outFl = fl} r
  fl:r -> parseArgs action{inFl = fl} r

execute action
  | help action = do
    mapM_ putStrLn $
      [ appname ++ ": " ++ appversion
      , "usage:"
      , "\t" ++ appname ++ " [OPTIONS...] <FILE>"
      , "  where OPTIONS are"
      , "    -c, --columns N      Number of columns in each page for the output (default is " ++ (show $ nColumns defaultAction) ++ ")."
      , "    -o, --output FILE    Writes output to FILE instead of stdout."
      ]
  | null $ inFl action = execute action{help = True}
  | otherwise = do
      lst <- readFile $ inFl action
      let ws    = map (span (\x -> x /= '\t' && x /= ' ')) $ lines lst
          pref  = (length $ fst $ head ws) - 3
          pages = groupBy (\(x,_) (y,_) -> (take pref x) == (take pref y)) ws
          text  = concatMap (\p -> latexify p (nColumns action) pref) pages
      if null $ outFl action then putStr text else writeFile (outFl action) text
      --mapM_ (\p -> putStr $ latexify p (nColumns action) pref) pages



main = do
  args <- getArgs
  let action = parseArgs defaultAction args
  execute action

