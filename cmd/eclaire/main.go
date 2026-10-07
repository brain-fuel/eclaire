package main

import (
	"fmt"
	"os"

	"github.com/brain-fuel/eclaire/bindings/go/eclaire"
)

func main() {
	if len(os.Args) > 2 || (len(os.Args) == 2 && os.Args[1] != "version" && os.Args[1] != "--version" && os.Args[1] != "--help") {
		fmt.Fprintln(os.Stderr, "Usage: eclaire [version|--version|--help]")
		os.Exit(2)
	}
	if len(os.Args) == 2 && (os.Args[1] == "--help") {
		fmt.Println("Usage: eclaire [version|--version|--help]")
		return
	}
	fmt.Printf("Eclaire %s (IR %d, Clay %s)\n", eclaire.Version, eclaire.IRVersion(), eclaire.ClayCommit)
}
