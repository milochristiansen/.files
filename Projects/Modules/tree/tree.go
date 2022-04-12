package main

import (
	"fmt"
	"os"
	"sort"

	"github.com/alessio/shellescape"
	"golang.org/x/term"
)

const (
	T         = "├── "
	I         = "│   "
	L         = "└── "
	O         = "    "
	PrefixLen = 4
)

const (
	// Dark colors
	Black     = "\033[0;30m"
	Red       = "\033[0;31m"
	Green     = "\033[0;32m"
	Brown     = "\033[0;33m"
	Blue      = "\033[0;34m"
	Purple    = "\033[0;35m"
	Cyan      = "\033[0;36m"
	LightGray = "\033[0;37m"
	// Light Colors
	DarkGray    = "\033[1;30m"
	LightRed    = "\033[1;31m"
	LightGreen  = "\033[1;32m"
	Yellow      = "\033[1;33m"
	LightBlue   = "\033[1;34m"
	LightPurple = "\033[1;35m"
	LightCyan   = "\033[1;36m"
	White       = "\033[1;37m"
	// Other
	EndColor    = "\033[0m"
	ClearScreen = "\033[2J\033[u"
)

var FileLimit = 20

var Width = 0
var Filters = map[string]bool{".git": true, "node_modules": true}

func main() {
	width, _, err := term.GetSize(int(os.Stdin.Fd()))
	if err != nil {
		fmt.Println(err)
		return
	}
	Width = width

	fmt.Printf("%v.\n", ClearScreen)

	for i := 1; i < len(os.Args); i++ {
		Filters[os.Args[i]] = true
	}

	walkDIR(".", []string{}, 0)
}

func walkDIR(path string, depths []string, limit int) {
	d, err := os.Open(path)
	if err != nil {

	}

	files, err := d.Readdir(-1)
	d.Close()
	if err != nil {

	}
	sort.Slice(files, func(i, j int) bool {
		// Files before directories
		if !files[i].IsDir() && files[j].IsDir() {
			return false
		}
		if files[i].IsDir() && !files[j].IsDir() {
			return true
		}

		return files[i].Name() < files[j].Name()
	})

	if len(files) > limit && limit != 0 {
		fmt.Printf("%v%v...%v\n", prefix(depths, L), LightRed, EndColor)
		return
	}
	if limit == 0 {
		limit = FileLimit
	}

	aS, aI, aF := "", 0, true
	for i, f := range files {
		last := T
		mypre := I
		if i == len(files)-1 {
			last = L
			mypre = O
		}

		if f.IsDir() {
			fmt.Printf("%v%v%v%v/\n", prefix(depths, last), LightBlue, f.Name(), EndColor)
			if Filters[f.Name()] {
				fmt.Printf("%v%v...%v\n", prefix(append(depths, mypre), L), LightRed, EndColor)
				continue
			}
			walkDIR(path+"/"+f.Name(), append(depths, mypre), limit)
			continue
		}

		name, nl := massageName(f)
		if Width == 0 {
			fmt.Printf("%v%v\n", prefix(depths, last), name)
			continue
		}

		pre := len(prefix(depths, L))
		if (pre+aI+3+nl) > Width && aI > 0 {
			if aF {
				fmt.Printf("%v%v\n", prefix(depths, L), aS)
			} else {
				fmt.Printf("%v%v\n", prefix(depths, O), aS)
			}
			aF = false
			aS = ""
			aI = 0
		}
		if aS != "" {
			aS += "   "
			aI += 3
		}
		aI += nl
		aS += name
	}
	if aS != "" {
		if aF {
			fmt.Printf("%v%v\n", prefix(depths, L), aS)
		} else {
			fmt.Printf("%v%v\n", prefix(depths, O), aS)
		}
	}
}

func massageName(f os.FileInfo) (string, int) {
	name := f.Name()

	color := EndColor
	switch getExt(name) {
	case ".sh":
		color = Red
	case ".go":
		color = Purple
	case ".md":
		color = Cyan
	case ".vue":
		color = Green
	case ".js":
		color = Green
	case ".html":
		color = Green
	}

	switch name {
	case ".gitignore":
		fallthrough
	case "go.sum":
		fallthrough
	case "go.mod":
		fallthrough
	case "LICENSE":
		fallthrough
	case "TODO":
		fallthrough
	case "CHANGELOG":
		fallthrough
	case "VERSION":
		color = Red
	case "Makefile":
		fallthrough
	case "Dockerfile":
		color = Brown
	}

	suffix := ""
	if f.Mode().Perm()&0111 != 0 {
		suffix = "*"
	}

	name = shellescape.Quote(name)

	return fmt.Sprintf("%v%v%v%v", color, name, EndColor, suffix), len(name) + len(suffix)
}

func prefix(depths []string, last string) string {
	rtn := ""
	for _, pre := range depths {
		rtn += pre
	}

	return rtn + last
}

// getExt returns the extension from a file name.
func getExt(name string) string {
	// Find the last part of the extension
	i := len(name) - 1
	for i >= 0 {
		if name[i] == '.' {
			return name[i:]
		}
		i--
	}
	return ""
}
