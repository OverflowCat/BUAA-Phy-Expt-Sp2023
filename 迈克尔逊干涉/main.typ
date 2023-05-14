// ========================
// 填写你的实验数据
#let N = 100 // 条纹间隔数
#let d_i = (55.00000, 55.03458, 55.06640, 55.09297, 55.12003, 55.15090, 55.19368, 55.22506, 55.25732, 55.28862) // 逐差法记录的实验数据
// Other data:
// #let d_i = (55.05000, 55.08649, 55.11875, 55.15045, 55.18171, 55.21320, 55.24510, 55.27655, 55.30844, 55.34005)
// #let d_i = (54.04000, 54.07185, 54.10363, 54.13540, 54.16767, 54.20000, 54.23215, 54.26392, 54.29560, 54.32775)
// #let d_i = (51.62000, 51.65242, 51.68486, 51.71693, 51.74861, 51.78051, 51.81233, 51.84357, 51.87528, 51.90672) // correct
// #let d_i = (54.33550, 54.36760, 54.39978, 54.43289, 54.46605, 54.49792, 54.52948, 54.56099, 54.59280, 54.62401
// ========================

#import "util.typ": sci, fin_res, c2, c5, c8, avg, 逐差

#let delta_5_d_i = 逐差(d_i)

$N = #N$
#table(
  columns: (auto, auto, auto, auto, auto, auto),
  inset: 10pt,
  align: horizon,
  $i$, [1], [2], [3], [4], [5],
  $d_i$, ..(0,1,2,3,4).map(i => $#d_i.at(i)$),
  $i$, [6], [7], [8], [9], [10],
  $d_i$, ..(0,1,2,3,4).map(i => $#d_i.at(i+5)$),
  // $Delta d_i$, ..(0,1,2,3,4).map(i => $Delta d_#str(i+1)$),
  // 这样表述是错误的．下面的 Delta d 是指 1/5*(d_(i+5)-d_i)．有的人写的报告的　Delta d 是 d_(i+5)-d_i
  $d_(i+5) - d_i"/mm"$, ..delta_5_d_i.map(x => $#x$)
)

// #let half_lambda = delta_d_i.sum() / delta_d_i.len() / (5 * N)
#let delta_d = avg(delta_5_d_i) / 5

// $ lambda / 2 = (Delta d_1 + Delta d_2 + Delta d_3 + Delta d_4 + Delta d_5) / (#delta_d_i.len() times 5N) = #sci(half_lambda) "mm." $
$ Delta d = (Delta_5 d_1 + Delta_5 d_2 + Delta_5 d_3 + Delta_5 d_4 + Delta_5 d_5) / (5 times 5) = #sci(delta_d) "mm." $

#let lambda_ = 2 * delta_d / N
#let lambda_nm = sci(lambda_*1e6)

$ lambda = (2 Delta d) / N = (2 times #c5(delta_d)) / #N= #c8(lambda_) = #lambda_nm "nm". $

#let 相对误差 = calc.abs((lambda_*1e6 - 632.8) / 632.8) * 100

$ "相对误差" = (#lambda_nm - 632.8) / 632.8 = #c2(相对误差)%. $

=== 不确定度

#let delta_d_i = delta_5_d_i.map(x => x/5)
#table(
  columns: (auto, auto, auto, auto, auto, auto),
  inset: 10pt,
  align: horizon,
  [$i$], [1], [2], [3], [4], [5],
  [$Delta d_i$], ..delta_d_i.map(x=>[$#c5(x)$]),
)

#let sq = x => calc.pow(x, 2)

/*
#let delta_d_i_avg = avg(delta_d_i)
#let u_a_mm = calc.sqrt(delta_d_i.map(x => sq(x - delta_d_i_avg)).sum() / (delta_d_i.len() - 1))
$ u_a(Delta d) = sqrt((sum(Delta d_i - overline(Delta d))^2) / (#delta_d_i.len() - 1)) = #sci(u_a_mm) "mm". $
*/

#let delta_5_d_i_avg = avg(delta_5_d_i)
#let u_a_mm = calc.sqrt(delta_5_d_i.map(x => sq((x - delta_5_d_i_avg)/5)).sum() / (5 * 4))
$ u_a(Delta d) = sqrt((sum(Delta_5 d_i - overline(Delta_5 d))^2)/(5 times 4)) = #sci(u_a_mm) "mm". $

#let u_b_mm = 1e-5/calc.sqrt(3)
$ u_b(Delta d) = Delta_仪/sqrt(3) = #sci(u_b_mm) "mm". $

#let u_mm = calc.sqrt(sq(u_a_mm) + sq(u_b_mm))

$ u(Delta d) = sqrt(u_a^2(Delta d) + u_b^2(Delta d)) = #sci(u_mm) "mm," $

条纹连续读数误差 $Delta N <= 1.$

#let delta_N = 1
#let u_N = 1/5 * delta_N / calc.sqrt(3) // 注意这里的 1/5！
$ u(N) = 1/5 dot (Delta N) / sqrt(3) = #c5(u_N). $

#let u_lambda_div_lambda = calc.sqrt(sq(u_mm/delta_d) + sq(u_N/N))
$ u(lambda)/lambda = sqrt((u(Delta d)/(Delta d))^2 + (u(N)/N)^2) = #sci(u_lambda_div_lambda). $
#let u_lambda = u_lambda_div_lambda * lambda_
$ u(lambda) = lambda dot u(lambda)/lambda = #sci(u_lambda) "mm". $

最终表述：

#fin_res(lambda_, u_lambda, symbol: $lambda$, unit: " mm")

#fin_res(lambda_*1e-3, u_lambda*1e-3, symbol: $lambda$, unit: " m")

#fin_res(lambda_*1e6, u_lambda*1e6, symbol: $lambda$, unit: " nm")
