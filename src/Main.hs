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

breaks :: [a] -> Int -> [[a]]
breaks [] _ = []
breaks xs n = (take n xs) : (breaks (drop n xs) n)

latexify page columns =
  concat
  [ "\\setcounter{dice}{", pageNum ,"}\n"
  , "\\begin{table}[bp]\n\\centering\n\\begin{tabular}{", concat $ take columns $ repeat "r l|", "}\n"
  , texpage cls
  , "\\end{tabular}\n\\end{table}\n"
  , "\\clearpage\n"
  ]
  where
    n = ceiling $ (fromIntegral $ length page) / (fromIntegral columns)
    cls = breaks page n
    pageNum = take 2 $ fst $ head $ head cls

texpage :: [[(String, String)]] -> String
texpage [] = []
texpage cls
  | and $ map null cls = []
  | otherwise =
    texline (map mhead cls) ++ texpage (map mtail cls)
    where
      mhead [] = ("", "")
      mhead (x:xs) = x
      mtail [] = []
      mtail (x:xs) = xs

texcell :: (String, String) -> String
texcell ("",_) = "&"
texcell (pos,word) =
  concat ["& ", texpos $ drop 2 pos, ": &", "\\textbf{", tail word, "} "]
  where
    texpos pos = if and $ map (=='1') (tail pos) then "\\underline{" ++ pos ++ "}"  else (" " ++ tail pos)


texline :: [(String, String)] -> String
texline ln =
  (tail $ concatMap texcell ln) ++ "\\\\\n"

main = do
  args <- getArgs
  if length args == 0 then
    putStrLn "usage: dice2tex <FILE>"
    else do
      let fl = head args
      lst <- readFile fl
      let ws = map (span (\x -> x /= '\t' && x /= ' ')) $ lines lst
      let pages = groupBy (\(x,_) (y,_) -> (take 2 x) == (take 2 y)) ws
      mapM_ (\p -> putStr $ latexify p 4) pages
