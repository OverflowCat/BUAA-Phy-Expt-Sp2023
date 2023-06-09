#import "template.typ": *
#let pow = calc.pow
#let PI = calc.pi

#let to_int(degreef) = {
  let min = calc.rem(degreef, 1) * 60
  int(int(degreef) * 100 + min)
}

#let t5(f) = calc.round(f, digits: 5)

#let sci(num) = {
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
// #assert(sci(-0.0112343245) == $-1.12343 times 10^(-2)$)

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
    let tens = pow(10, offset)
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

#show: project.with(
  // Take a look at the file `template.typ` in the file panel
  // to customize this template and discover how it works.
  title: "氢原子光谱和里德伯常数的测量",
  authors: (
    (name: "OverflowCat", email: "overflowcat@gmail.com"),
  ),
)

= 数据处理

== 校准光栅常数

=== 原始数据列表

#let di(int) = {
  let deg = calc.floor(int / 100)
  $deg degree #calc.rem(int, 100)'$
}

#let getdigit(angle) = {
    if angle < 0 {
        calc.ceil(angle / 100)
    } else {
        calc.floor(angle / 100)
    }
}

#let sum_angles(angle1, angle2) = {
    let angle1_deg = getdigit(angle1)
    let angle1_min = calc.rem(angle1, 100)
    let angle2_deg = getdigit(angle2)
    let angle2_min = calc.rem(angle2, 100)
    let degree_sum = angle1_deg + angle2_deg
    let minute_sum = angle1_min + angle2_min
    while minute_sum >= 60 {
        minute_sum -= 60
        degree_sum += 1
    }
    while minute_sum <= -60 {
        minute_sum += 60
        degree_sum -= 1
    }
    if degree_sum > 0 and minute_sum < 0 {
        minute_sum += 60
        degree_sum -= 1
    }
    if degree_sum < 0 and minute_sum > 0 {
        minute_sum -= 60
        degree_sum += 1
    }
    degree_sum * 100 + minute_sum
}

#assert(sum_angles(0, 0) == 0)
#assert(sum_angles(100, 100) == 200)
#assert(sum_angles(230, 130) == 400)
#assert(sum_angles(359, 1) == 400)
#assert(sum_angles(-123, -456) == -619)
#assert(sum_angles(-1150, -2110) == -3300)

#let coeff_angle(angle, coe) = {
  assert(coe <= 1, message: "Coeff should be leq than 1")
  assert(coe >= 0, message: "Coeff should be geq than 0")
  let aangle = calc.abs(angle)
  let angle_deg = getdigit(angle)
  let angle_min = calc.rem(angle, 100)
  angle_deg *= coe
  angle_min *= coe
  angle_min += calc.rem(angle_deg, 1) * 60
  angle_deg = calc.floor(angle_deg)
  angle_deg * 100 + calc.round(angle_min)
}

#assert(coeff_angle(102, .5) == 31, message: "Angle should be positive")

#let to_degreef(angle) = {
  let angle_deg = getdigit(angle)
  let angle_min = calc.rem(angle, 100)
  angle_deg += angle_min / 60
  angle_deg
}

#let calc_theta(a1, b1, a2, b2) = {
  coeff_angle(sum_angles(sum_angles(a1, -a2), sum_angles(b1, -b2)), .5)
}

#assert(calc_theta(5924, 23922, 1628, 19625) == 4257)
// (59 24 - 16 28 + 23922 - 19625) / 2
// = 42 56 + 42 57 = 42 56.5

#let line(a1, b1, a2, b2) = {
  (a1, b1, a2, b2, calc_theta(a1, b1, a2, b2)).map(di)
}

#let data = (
  (05924, 23922, 01628, 19625),
  (34901, 16903, 30556, 12653),
  (31246, 13243, 26943,  8940),
  (2826 + 36000, 20725, 34502, 16501),
  (15516, 33515, 11305, 29306),
) // 下面还有一处需要修改

#table(
  columns: (auto, auto, auto, auto, auto, auto),
  inset: 10pt,
  align: horizon,
  [*测量级次*], [$-2$], [$-2$], [$+2$], [$+2$], [],
  [*组数*], [$alpha_1$], [$beta_1$], [$alpha_2$], [$beta_2$], [$2 theta_i$],
  $1$, ..line(..data.at(0)),
  $2$, ..line(..data.at(1)),
  $3$, ..line(..data.at(2)),
  $4$, ..line(..data.at(3)),
  $5$, ..line(..data.at(4)),
)

=== 计算光栅常数

#let sum_multi_angles(arr) = {
  arr.fold(0, sum_angles)
}

#let double_thetas = data.map(x => calc_theta(..x))

#let double_theta_val = coeff_angle(sum_multi_angles(double_thetas), .2)

$ 2 overline(theta) = 1/5 sum^5_(i=1) theta_i = #di(double_theta_val), $

#let theta_val = int(coeff_angle(double_theta_val, .5))

$ theta = #di(theta_val) $

由 $d sin theta = k lambda$, $k=2$, 得

#let thetaf = to_degreef(theta_val)
#let to_rad = x => PI / 180 * x
#let theta_rad = to_rad(thetaf)
#let sin_theta = calc.sin(theta_rad)
#let cos_theta = calc.cos(theta_rad)
#let d = 2 * 589.3 * 1e-9 / sin_theta

$ d = (k lambda) / (sin theta) = (2 times 589.3 times 10^(-9)) / (sin #calc.round(thetaf, digits: 3) degree) = #{calc.round(d, digits: 10) * 1e6} "μm" $

=== 计算不确定度 $u(d)$

#let diffs=double_thetas.map(to_degreef).map(to_rad). map(rad => rad / 2 - theta_rad)
$ u_"a"(2 theta) = sqrt(sum (theta_i - overline(theta))/(5 times 4))$
$ = sqrt(#{"(" + diffs.map(x => calc.round(x, digits: 3)).map(str).join(")² + (") + ")²"} / (5 times 4)) $
#let u_a_2theta = calc.sqrt(diffs.map(x => pow(x, 2)).fold(0, (x, y) => x + y) / (5 * 4))
$ = #sci(u_a_2theta) "rad." $

#let u_b_2theta = to_rad(1/60) / (1 * calc.sqrt(3))
$ u_"b"(2 theta) = Delta_(2 theta) / (sqrt(3)) /* times 1/2 */ = (1') / sqrt(3) /* times 1/2 */ = #sci(u_b_2theta) "rad." $
// !!! 注意这里如果是 u_b(theta) 才有 1/2，因为 theta = |theta_(+) - theta_(-)|/2. 参见下面计算 Rydberg 常量的时候
// 不过倒是对最后的不确定度那一位贡献不大

#let u_2theta = calc.sqrt(u_a_2theta * u_a_2theta + u_b_2theta * u_b_2theta)
$ u(2 theta) = sqrt((u_"a"(theta))^2 + (u_"b"(theta))^2) = #sci(u_2theta) "rad." $
#let u_theta = 1/2 * u_2theta
$ u(theta) = u_2theta / 2 = #sci(u_theta) "rad." $
// #let u_d = calc.round(calc.sqrt(pow(2 * 589.3 * 1e-9 * calc.cos(theta_rad) / calc.sin(theta_rad) * u_theta, 2)), digits: 14)

$ u(d) = sqrt(((diff d) / (diff theta)) ^ 2 u^2(theta)) = sqrt((-(k lambda cos θ)/(sin^2 θ)) ^ 2 u^2(θ)) $
#let u_d = calc.sqrt(pow(-2 * 589.3 * 1e-9 * cos_theta / sin_theta / sin_theta, 2) * pow(u_theta, 2))
$ = #t5(u_d * 1e9) "nm."
=#sci(u_d) "m".$

=== 最终表述

$ #fin_res(d, u_d, symbol: $d$, unit: "m") $

// #let u_d_alt = d * (u_theta / calc.tan(theta_rad))
// $ u(d) = (cos theta)/((sin theta)^2) u(theta) = #u_d $
// $ = #{u_d_alt * 1e6} "μm" $

== 氢原子光谱

=== 数据列表

#let blue3 = (
  a: (
      m: 14101,
      p: 8858,
  ),
  b: (
      m: 32057,
      p: 26855,
  ),
)
#let blue1 = (
  a: (
    m: 12331,
    p: 10654,
  ),
  b: (
    m: 30329,
    p: 28651,
  ),
)
#let red1 = (
a: (
    m: 12628,
    p: 10345,
  ),
  b: (
    m: 30628,
    p: 28344,
  ),
)

#let calc_tc(x) = {
  let diffa = to_degreef(x.a.p) - to_degreef(x.a.m)
  let diffb = to_degreef(x.b.p) - to_degreef(x.b.m)
  (calc.abs(diffa) + calc.abs(diffb)) / 4
}

#let tblue3 = calc_tc(blue3)
#let tblue1 = calc_tc(blue1)
#let tred1 = calc_tc(red1)

$ theta_(3蓝) = #di(to_int(tblue3)) $
$ theta_(1蓝) = #di(to_int(tblue1)) $
$ theta_(1红) = #di(to_int(tred1)) $

=== 计算里德伯常数

由 $k lambda = d sin theta, 得 lambda = (d sin theta) / k.$ 又
$ R_H = 1/(lambda(1/(m^2)-1/(n^2))), $ 本实验中观察的谱线为巴尔末线系，$n=2$，故 $ R_H = 1/(lambda(1/4-1/(n^2))). $
本实验中，每个颜色的每级谱线仅测量一次，故
#let u_b_theta = to_rad(1/60) / (2 * calc.sqrt(3))
$ u(θ_i) = u_"b"(theta) = Delta_(θ_i) / sqrt(3) ⋅ 1 / 2 = (1') / (2 sqrt(3)) = 8.3972 times 10^(-5) "rad." $
$ u(λ_i) = sqrt(
    ((diff λ) / (diff d)) ^2 u^2(d) +
     ((diff λ) / (diff θ_i)) ^2 u^2 θ_i
  ) = sqrt(
    sin^2 θ_i (u(d))^2 +
    (d cos θ_i)^2 u^2(θ_i))
  ).
$
$
u(R_("H"i))
= sqrt(((diff R_("H"i))/(diff λ_i))^2 u^2(λ_i))
= sqrt(1/(1/(m^2) - 1/(n^2)) (-1/(λ_i^2))^2 u^2(λ_i))
= 1/(1/4 - 1/(n^2)) |-u(λ_i)/(λ_i^2) |
$

#let calc_rf(color, lv, degreef) = {
  let R_name = $R_(H#lv#color)$
  let θ_name = $θ_(#lv#color)$
  let λ_name = $λ_(#lv#color)$
  [==== #{"由" + color + "光"} #lv 级计算]
  [#{"对于" + color + "光"} #lv 级，]
  let rad = to_rad(degreef)
  let sin_theta = calc.sin(rad)
  let cos_theta = calc.cos(rad)
  let lambda_val = d * sin_theta / lv
  [$#θ_name = #t5(rad) "rad"$，]
  [故 $#λ_name = (d sin #θ_name) / #lv = #t5(lambda_val * 1e9) "nm."$ ]
  let n = if color == "红" { 3 } else { 4 }
  [#color 光对应的 $n=#n$，]
  let R_H = 1 / lambda_val / (1/(2*2) - 1/(n*n))
  [所以 $#R_name = 1/(#λ_name (1/(2^2)-1/(#n^2))) = #t5(R_H/1e7) times 10^7 "m"^(-1).$]
  let u_theta = u_b_theta
  let u_lambda = calc.sqrt(pow(u_d * sin_theta, 2) + pow(d * cos_theta * u_theta, 2))

  let u_R_H = 1/(1/4-1/n/n) * (1/pow(lambda_val, 2)) * u_lambda
  $ u(#λ_name) =
  sqrt(#sci(sin_theta)^2 (#sci(u_d))^2 +
  (#sci(d) times #sci(cos_theta))^2 (#sci(u_theta))^2) $
  $= #sci(u_lambda)" m".$
  $ u(#R_name) = 1/(1/(2^2) - 1/(#n^2)) #sci(u_lambda) / (#sci(lambda_val))^2 $
  $= #calc.round(u_R_H)" m"^(-1).$
  $ #fin_res(R_H, u_R_H, symbol: $#R_name$, unit: $"m"^(-1)$) $
  $ (#R_name = #t5(R_H) ± #t5(u_R_H)) $
}

#calc_rf("红", 1, tred1)

#calc_rf("蓝", 1, tblue1)

#calc_rf("蓝", 3, tblue3)

=== 最佳测量值

#let r_data = (
  (11297078.796975119, 20733.80762789463),
  (11403779.912416829, 21407.90265727418),
  (11274282.771356964, 60724.88317105589),
) // 此处的数据需要用鼠标中键垂直选中后，鼠标悬浮在 R_H, u_R_H 上，选中弹出的提示，右键复制文本，把数据复制过来．

#let 分子各项 = r_data.map(x => $#calc.round(x.at(0)) / #calc.round(x.at(1)) ^2$)
#let 分母各项 = r_data.map(x => $1 / #calc.round(x.at(1)) ^2$)
#let 分子 = r_data.map(x => x.at(0) / pow(x.at(1), 2)).fold(0, (x, y) => x + y)
#let 分母 = r_data.map(x => 1 / pow(x.at(1), 2)).fold(0, (x, y) => x + y)
#let R_H_avg = 分子/分母
#let u_R_H_avg = 1/pow(分母, .5)

由公式 $λ= (d sin theta) / k$ 知 $u(lambda)$ 与级数 $k$ 有关，即不同级数的波长测量精度不同，须加权平均：

$
overline(R)
= (sum (R_(H i))/(u^2 (R_(H i)))) / (sum 1/(u^(2) (R_(H i))))
= #分子各项.join($+$) / #分母各项.join($+$)
$
$ = #t5(分子) / #sci(分母) = #calc.round(R_H_avg) "m"^(-1). $
$ u(overline(R_H))= sqrt(1 / (sum 1/(u^2 (R_(H i))))) $
$ = (#分母各项.join($+$))^(-1/2) = #t5(u_R_H_avg). $

里德伯常数最佳测量值为
$ #fin_res(R_H_avg, u_R_H_avg, symbol: $overline(R_"H")$, unit: $ "m"^(-1)$) $

=== 误差分析

#let R_theo = 1.0973731569 * 1e7

与里德伯常数标准值 $R_(H 标 准) = #{R_theo * 1e-7} times 10^(7) "m"^(-1)$ 相比较，其相对误差为
$ δ=|R_(H)-R_(H 标 准)|/R_(H 标 准) times 100% = #t5(calc.abs(R_H_avg - R_theo)/R_theo*100)%. $

== 钠黄光的角色散率和分辨率本领

#{
  let k = 2
  let D_theta_k = k / (d * cos_theta)
  $ k = #k, "角色散率" D_(theta #k) = (diff theta) / (diff lambda) = k / (d cos theta) = #k / (#sci(d) times #t5(cos_theta)) = #t5(D_theta_k) "rad/m". $
  let 通光口径 = 2.20 * 1e-2
  let 色分辨率 = 1 * 通光口径 / d
  [
    平行光管的通光口径 $D=2.20 "cm"$，光栅的色分辨率为
    $ R = k N = (k D)/d = (1 times 0.0220) / #sci(d) = #t5(色分辨率). $
    当 $R=k N > lambda / (diff lambda)$ 时，说明波长为 $lambda$，波长差为 $diff lambda$ 的两束光可以被分辨．
    $ lambda / (diff lambda) = 589.3 / 0.6 = #t5(589.3/.6) << #t5(色分辨率) = R, $
    这一计算结果表明钠黄光的双线可以被分开．
  ]
}

= 思考题

1. 虽然光栅可以分开钠黄光的双线，但实验中并没有观察到这一现象．实际上人眼无法分辨，所以本实验不能将钠黄光的双线分开．(证明方法见 `README.md`)
