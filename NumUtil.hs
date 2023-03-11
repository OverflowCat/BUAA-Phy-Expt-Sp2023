module NumUtil (四舍五入, 四舍五入1位) where


四舍五入 x n = fromIntegral (round (x * t)) / t
  where t = 10^n

四舍五入1位 x = 四舍五入 x 1
