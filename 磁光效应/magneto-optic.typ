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

=== 磁场强度

磁头间距：$10 "mm"$
#let I_mA = range(0, 2800, step:100) //
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
  [$I"/A"$], ..range(20,28).map(i=>$#ff(I_A.at(i),1)$),[],[],
  [$B"/mT"$], ..range(20,28).map(i=>$#B_mT.at(i)$),
)

=== 偏转角度

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

== 一元线性回归法处理数据

由 $theta = V B D$, $ V = theta / (B d). $
