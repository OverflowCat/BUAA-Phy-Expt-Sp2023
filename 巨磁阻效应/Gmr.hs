import NumUtil

计算磁感应强度 i = 4 * pi * 24000 * 1e-7 * i / 1000 * 1e4

-- Experiment 1

e1_励磁电流 =
  [ 100.0,
    90.0,
    80.0,
    69.9,
    60.1,
    50.0,
    40.0,
    30.0,
    19.9,
    9.9,
    0.0,
    --
    -10.2,
    -20.0,
    -30.2,
    -39.9,
    -50.0,
    -59.9,
    -70.3,
    -80.1,
    -90.1,
    -100.3,
    --
    -90.1,
    -80.1,
    -70.0,
    -60.0,
    -50.0,
    -39.8,
    -30.0,
    -20.0,
    -10.0,
    -0,
    --
    10.1,
    20.2,
    30.1,
    40.1,
    50.0,
    60.0,
    70.2,
    79.8,
    90.0,
    100.0 -- /mA
  ]

e1_磁感应强度 = map 计算磁感应强度 e1_励磁电流

-- $$ B = \mu_0 n I $$

-- $n$ 是线圈匝数，实验中是 24000; $\mu_0 = 4\pi \times 10^{-7} \mathrm{H/m}$ 为真空磁导率.
-- 使用 SI 计算时结果单位为特斯拉(T) = 1*10^4 高斯(G or Gs). 这里的结果已经换算成了高斯.

-- Experiment 2

e2_励磁电流 =
  [ [ 100.0,
      90.0,
      79.8,
      70.0,
      59.9,
      49.9,
      39.9,
      30.1,
      20.0,
      10.1,
      0.0
    ],
    --
    [ -10.1,
      -20.1,
      -30.1,
      -40.0,
      -50.6,
      -60.0,
      -70.2,
      -80.0,
      -90.1,
      -100.0
    ],
    --
    [ -89.9,
      -80.0,
      -70.1,
      -60.0,
      -49.9,
      -40.1,
      -30.1,
      -20.0,
      -9.7,
      -0.0
    ],
    --
    [ 10.2,
      19.9,
      30.1,
      40.0,
      49.8,
      59.9,
      70.5,
      80.0,
      89.9,
      100.0 -- /mA
    ]
  ]

e2_磁感应强度 = map (map 计算磁感应强度) e2_励磁电流

e2_v = 4.0 -- 电压为 4 V

e2_磁阻电流 =
  -- mA
  [ [ 1.937,
      1.934,
      1.926,
      1.907,
      1.878,
      1.845,
      1.809,
      1.773,
      1.739,
      1.709,
      1.680
    ],
    --
    [ 1.701,
      1.731,
      1.765,
      1.801,
      1.843,
      1.877,
      1.908,
      1.926,
      1.934,
      1.936
    ],
    --
    [ 1.935,
      1.928,
      1.912,
      1.885,
      1.852,
      1.818,
      1.782,
      1.746,
      1.714,
      1.687
    ],
    --
    [ 1.695,
      1.724,
      1.758,
      1.794,
      1.831,
      1.869,
      1.903,
      1.923,
      1.933,
      1.936
    ]
  ]

e2_磁阻 = [[e2_v / (i / 1000) | i <- e2_磁阻电流_sublist] | e2_磁阻电流_sublist <- e2_磁阻电流]

-- Experiment 3

e3_电流 =
  -- 50 → 0 → -50 → 0 → 50
  [12.6, -14.6, -12.6, 15.7] -- mA
  -- 1 → -1 → 1 → -1 → 1

e3_磁感应强度 = map 计算磁感应强度 e3_电流
-- [3.800,-4.403,-3.800,4.735]

main :: IO ()
main = do
  putStrLn "### 实验 1 ###"
  putStrLn "= 磁感应强度 ="
  print (map 四舍五入1位 e1_磁感应强度)
  {- [30.2,27.1,24.1,21.1,18.1,15.1,12.1,9.0,6.0,3.0,0.0,
      -3.1,-6.0,-9.1,-12.0,-15.1,-18.1,-21.2,-24.2,-27.2,-30.2,
      -27.2,-24.2,-21.1,-18.1,-15.1,-12.0,-9.0,-6.0,-3.0,0.0,
      3.0,6.1,9.1,12.1,15.1,18.1,21.2,24.1,27.1,30.2] -}
  putStrLn "================\n"

  putStrLn "### 实验 2 ###"
  putStrLn "= 磁感应强度 ="
  print (map (map 四舍五入1位) e2_磁感应强度)
  {- [[30.2,27.1,24.1,21.1,18.1,15.0,12.0,9.1,6.0,3.0,0.0],[-3.0,-6.1,-9.1,-12.1,-15.3,-18.1,-21.2,-24.1,-27.2,-30.2],[-27.1,-24.1,-21.1,-18.1,-15.0,-12.1,-9.1,-6.0,-2.9,0.0],[3.1,6.0,9.1,12.1,15.0,18.1,21.3,24.1,27.1,30.2]] -}
  putStrLn "= 磁阻 ="
  print (map (map 四舍五入1位) e2_磁阻)
  {- [[2065.0,2068.3,2076.8,2097.5,2129.9,2168.0,2211.2,2256.1,2300.2,2340.6,2381.0],[2351.6,2310.8,2266.3,2221.0,2170.4,2131.1,2096.4,2076.8,2068.3,2066.1],[2067.2,2074.7,2092.1,2122.0,2159.8,2200.2,2244.7,2291.0,2333.7,2371.1],[2359.9,2320.2,2275.3,2229.7,2184.6,2140.2,2101.9,2080.1,2069.3,2066.1]] -}
  putStrLn "================\n"

  putStrLn "### 实验 3 ###"
  putStrLn "= 磁感应强度 ="
  print [四舍五入 x 3 | x <- e3_磁感应强度]
