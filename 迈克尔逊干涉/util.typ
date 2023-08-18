// 四舍五入小数
#let c2 = x => calc.round(x, digits: 2)
#let c6 = x => calc.round(x, digits: 6)
#let c8 = x => calc.round(x, digits: 8)
#let c5(f) = calc.round(f, digits: 5)

// 科学计数法
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

#let 逐差 = (data) => {
  let half = int(data.len() / 2)
  let counter = 0
  let res = ()
  for value in data {
    if counter == half {
      break
    }
    let diff = data.at(counter + half) - value
    res.push(calc.round(diff, digits: 8))
    counter += 1
  }
  res
}

#let avg = (data) => {
  data.sum() / data.len()
}

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
