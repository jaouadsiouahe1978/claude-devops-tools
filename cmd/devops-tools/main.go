package main

import (
	"flag"
	"fmt"
	"os"

	"github.com/jaouadsiouahe1978/claude-devops-tools/internal/health"
	"github.com/jaouadsiouahe1978/claude-devops-tools/internal/version"
)

func main() {
	versionFlag := flag.Bool("version", false, "print version information")
	healthFlag := flag.Bool("health", false, "run health checks")
	flag.Parse()

	if *versionFlag {
		fmt.Println(version.Info())
		os.Exit(0)
	}

	if *healthFlag {
		if err := health.RunChecks(); err != nil {
			fmt.Fprintf(os.Stderr, "health check failed: %v\n", err)
			os.Exit(1)
		}
		fmt.Println("all health checks passed")
		os.Exit(0)
	}

	flag.Usage()
}
