locals {
  tags = {
    a = 1992
    b = 1993
  }
}

output this {
  value = join(",", values({ for t in keys(var.tags) : t => "${t}=${var.tags[t]}" }))
}
