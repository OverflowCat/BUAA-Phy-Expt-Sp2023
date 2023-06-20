#let avg = (data) => {
  data.sum() / data.len()
}

// cut
#let c1 = x => calc.round(x, digits: 1)
#let c2 = x => calc.round(x, digits: 2)
#let c3 = x => calc.round(x, digits: 3)
#let c4 = x => calc.round(x, digits: 4)
#let c5 = x => calc.round(f, digits: 5)
#let c6 = x => calc.round(x, digits: 6)
#let c7 = x => calc.round(x, digits: 7)
#let c8 = x => calc.round(x, digits: 8)
#let sci(num) = {
  if num < 0.000000000001 {
    return num
  }
  if calc.abs(num) >= 0.1 {
    return $#c5(num)$
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
  return $#sign#c5(num)times 10^#expn$
}
#let ff(num, digits) = {
  return if int(num) == num {
    str(num) + "." + "0" * digits
  } else {
    str(calc.round(num, digits: digits))
  }
}

= 磁光效应实验报告

== 原始数据列表

#let d_mm = 7.96
$ d = #d_mm "mm". $

==== 磁场强度
磁头间距：$10 "mm"$
#let I_mA = range(0, 2800+100, step:100) //
#let I_A = I_mA.map(x => x / 1000) //

#let B_mT = (0, 21, 40, 58, 79, 98, 123, 139, 158, 178, 196, 215, 235, 252, 272, 287, 302, 322, 336, 346, 358, 369, 379, 385, 392, 397, 404, 411, 415)

#table(
  columns: 11,
  inset: 9pt,
  align: end,
  [$I"/A"$], ..range(0,10).map(i=>$#ff(I_A.at(i),1)$),
  [$B"/mT"$], ..range(0,10).map(i=>$#B_mT.at(i)$),
  [$I"/A"$], ..range(10,20).map(i=>$#ff(I_A.at(i),1)$),
  [$B"/mT"$], ..range(10,20).map(i=>$#B_mT.at(i)$),
  [$I"/A"$], ..range(20,29).map(i=>$#ff(I_A.at(i),1)$),[],
  [$B"/mT"$], ..range(20,29).map(i=>$#B_mT.at(i)$),
)

== 作图

#image("plot.svg")

线性区域为 $[0, 1.2"A"]$，拟合方程为 $y=b x+a.$ 则其中 $y$ 为磁感应强度 $B$，$x$ 为电流强度．

\
\

即 $B=1.000000000 + 195.769230769I.$

== 偏转角度

#let theta_1_deg = (291, 111, 290, 108, 288) //
#let theta_2_deg = (297, 118, 298, 116, 294) //
#let Theta_deg = theta_1_deg.zip(theta_2_deg).map(((x, y)) => y - x)

#table(
  align: end,
  columns: 6,
  inset: 9pt,
  $theta_1"/"degree$, ..theta_1_deg.map(x => $#x$),
  $theta_2"/"degree$, ..theta_2_deg.map(x => $#x$),
  $Theta"/"degree$,   ..Theta_deg.map(x => $#x$)
)

$I=1.5"A"$ 时 $B=287"mT".$

#let res = 0.122173/0.287/7.96/.001

由 $theta = V B D$, $ V = theta / (B d)= (0.122173 "rad") / (287"mT" times 7.96"mm") = #c6(res)" rad" dot " T"^(-1) dot " m"^(-1). $

#let u_theta = calc.sqrt(4/20)

$ u(theta) = sqrt((sum (Theta_i-overline(Theta))^2)/((5-1)*4)) = sqrt((1^2+1^2+1^2+1^2)/20) = #c6(u_theta)degree = 0.00780535 "rad". $

#let u_B = calc.sqrt((19401.07692-14033.13609)/12)/1000

$ u(B) = u(y) = sqrt((sum overline(y^2)-overline(y)^2)/(13-1)) = sqrt((19401.07692-14033.13609)/12) "mT" = #c6(u_B)" T". $

#let u_V = res * calc.sqrt(calc.pow(0.00780535/0.122173, 2) + calc.pow(u_B/1.5, 2))

$ u(V) = V times sqrt(1/Theta^2 u^2(Theta) + 1/B^2 u^2(B)) $
$ = #c6(res) times sqrt( (#0.00780535^2)/(0.017453^2) + #u_B^2/(1.5^2)) = #c6(u_V) $

最终表述：


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

#fin_res(res, u_V, symbol: "T", unit: " rad/T/m")

= 思考题

1. 变小．
2.
*磁光隔离器*：在光纤通讯等场合中，反射光会严重干扰光源的正常输出，从而影响了整个系统的正常工作。磁光隔离器就是防止反向传输的干扰光对光源的影响，提高系统的工作稳定性。当光正向入射时，通过起偏器后成为线偏振光，再通过磁光介质与外磁场使光的偏振方向右旋45度，并恰好能通过与起偏器成45度放置的检偏器。而对于反向光，由检偏器射入的线偏振光经过放置介质时，偏转方向也右旋转45度，从而使反向光的偏振方向与起偏器方向成9O度，无法通过起偏器，从而实现正向通过，反向隔离的目的。

*磁光记录*：通过激光的热效应，改变稀土非晶合金薄膜的磁化矢量的取向，产生磁化矢量垂直于膜面的磁畴，利用该磁畴进行信息的写入；改变施加的磁场方向，经过同一激光的作用后就可逐点擦除已被记录的信息。
