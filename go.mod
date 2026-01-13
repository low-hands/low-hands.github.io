module github.com/low-hands/low-hands.github.io

go 1.24.3

require github.com/hugo-toha/toha/v4 v4.13.0 // indirect

replace(
    github.com/hugo-toha/toha/v4 => github.com/low-hands/toha/v4 main
)