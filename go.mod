module github.com/low-hands/low-hands.github.io

go 1.25

// 将官方主题路径替换为你自己的 Fork 仓库路径
replace github.com/hugo-toha/toha/v4 => github.com/low-hands/low-hands.github.io v0.0.0-20260113102618-6f4054a0625c

require github.com/hugo-toha/toha/v4 v4.13.1-0.20260105211530-3be17f2ed65a // indirect
