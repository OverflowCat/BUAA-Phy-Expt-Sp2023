= 双棱镜和劳埃镜干涉

#let t5(f) = calc.round(f, digits: 5)

#let sci(num) = {
  if num < 0.000000000001 {
    return num
  }
  if calc.abs(num) >= 0.1 {
    return $#t5(num)$
  }
  let sign = if num < 0 {
    num *= -1
    "-"
  } else {
    ""
  }
  let expn = 0
  while num < 1 {
    num *= 10
    expn -= 1
  }
  return $#sign#t5(num)times 10^#expn$
}

#let successive(data) = {
  assert(calc.rem(data.len(), 2) == 0)
  let res = ()
  let i = 0
  while i < data.len() / 2 {
    res.push(data.at(i + 10) - data.at(i))
    i += 1
  }
  res
}
#let sum(nums) = nums.fold(0, (x, y) => x + y)
#let avg(nums) = sum(nums) / nums.len()

#let L_1 = 55.02
#let L_2 = 74.37
#let K = 20.10
#let K_Delta = +1.20 // 修正值
#let S  = L_2 - (K + K_Delta) // .~~5435~~ 5307 m
#let S_ = L_1 - (K + K_Delta) // .3372 m
$ S = #S, S'= #S_ $
// 单位换算，注意是从厘米到米
#let S_plus_S_meter = (S + S_) / 100 * 1

#let x_i = (
  7.438, 7.179, 6.878, 6.597, 6.297, 6.099, 5.841, 5.598, 5.288, 5.062,
  4.767, 4.485, 4.187, 3.966, 3.658, 3.388, 3.142, 2.830, 2.601, 2.343
)

#let delta_10xs = successive(x_i).map(x => calc.round(x, digits: 5)).map(calc.abs)

#let abs = calc.abs
#let delta_x = abs(avg(delta_10xs)) / 10 * 1 // mm *

== 条纹间距

$Delta x: #delta_x "mm"$

== 计算

#let b = avg((calc.abs(2.538 - 5.902), calc.abs(2.519 - 5.849))) * 1
#let b_ = avg((calc.abs(3.898 - 5.167), calc.abs(3.788 - 5.060)))

#let lambda = delta_x * 1e-3 * calc.sqrt(b*1e-3 * b_*1e-3) / S_plus_S_meter

$ λ = (Delta x sqrt(b b'))/(S + S') = #{lambda*1e9} "nm" $

#let lambda_标准 = 650 * 1e-9
#let 误差 = calc.abs(lambda - lambda_标准)/lambda_标准*100

$ "误差" = #误差% $

== 不确定度

#let u_b = 0.005/calc.sqrt(3) * 1e-3

$ u_b(Delta_(10) x) = #sci(u_b) "m" $

#let delta_10x_avg = avg(delta_10xs)
#let diffs = delta_10xs.map(x => calc.abs(x - delta_10x_avg)).map(t5)

#table(
  columns: (1fr, 1fr, 1fr, 1fr),
  inset: 10pt,
  align: horizon,
  ..diffs.map(str)
)

#let u_a = calc.sqrt(1/(10-1) * sum(diffs.map(x => calc.pow(x, 2)))) * 1e-3

$ u_a(Delta_(10) x) = #sci(u_a) "m" $
#let u = calc.sqrt(u_a*u_a + u_b*u_b)
$ u(Delta_(10) x) = #sci(u) "m" $
#let u_delta_x = u / 10 * 1
$ u(Delta x) = #sci(u_delta_x) "m" $

#let u_b_b = u_b
#let u_b_b_ = u_b
#let u_a_b = calc.sqrt(calc.pow(3.364-b, 2) + calc.pow(3.330-b, 2)) * 1e-3
#let u__b = calc.sqrt(calc.pow(u_a_b, 2) + calc.pow(u_b_b, 2))
#let u_a_b_ = calc.sqrt(calc.pow(1.269-b_, 2) + calc.pow(1.272-b_, 2)) * 1e-3
#let u__b_ = calc.sqrt(calc.pow(u_a_b_, 2) + calc.pow(u_b_b_, 2))
$ u(b) = #sci(u__b) "m", u(b') = #sci(u__b_) "m" $

#let u_b_D = 0.5 * 1e-3 / calc.sqrt(3)
/* 长度测量仪器
• 钢板尺 最小分度的1/2计算(0.5mm)
• 千分尺 最小分度的1/2计算（0.005mm）aka 螺旋测微器
• 游标卡尺 游标精度
• 测微目镜有套筒 是千分尺
*/

// 单位换算．下次还是都用 mm 好了，老是弄错，麻了
#let b  = b  * 1e-3
#let b_ = b_ * 1e-3
#let delta_x = delta_x * 1e-3

#let u_S_plus_S_ = 0.5e-3 / calc.sqrt(3)
#let sq = x => calc.pow(x, 2)

#let _u_comps = (u_delta_x / delta_x, u__b / b, u__b_ / b_, u_S_plus_S_ / S_plus_S_meter)
#let _squared_u_comps = _u_comps.map(sq)
#let result = calc.sqrt(sum(_squared_u_comps))
// sq(u_delta_x / delta_x) + sq(u__b / b) + sq(u__b_ / b_) + sq(u_S_plus_S_ / S_plus_S_meter)

#let u_lambda = result * lambda

$ u(λ) / λ = #sci(result) $
$ u(λ) = #sci(u_lambda) = #{u_lambda * 1e9} "nm". $

#let fin_res(res, uncert, symbol: none, unit: none) = {
  let expn = 0
  while uncert <= 1 {
    uncert *= 10
    res *= 10
    expn -= 1
  }
  while uncert >= 10 {
    uncert /= 10
    res /= 10
    expn += 1
  }
  let offset = str(calc.round(res)).len() - 1
  if offset > 0 {
    let tens = calc.pow(10, offset)
    uncert /= tens
    res /= tens
    expn += offset
  }
  res = calc.round(res, digits: offset)
  uncert = calc.round(uncert, digits: offset)
  let res_s = str(res)
  let uncert_s = str(uncert)
  while res_s.len() < uncert_s.len() {
    res_s += "0" // 补末位 0
  }
  if symbol != none {
    $#symbol ± u(#symbol) =$
  }
  $(#res_s ± #uncert_s) times 10^#expn$
  if unit != none {
    $#unit$
  }
  $.$
}

$ #fin_res(lambda, u_lambda, symbol: $λ$, unit: " m") $

== 思考题

1. 根据你的测量数据，定量讨论哪个（些）量的测量对结果准确度的影响最大？原因何在？
2. 请查阅文献例举分波前干涉实验的现代应用及原理（至少 2 条）．
