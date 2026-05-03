package version

import "fmt"

var (
	Version   = "0.1.0"
	GitCommit = "unknown"
	BuildDate = "unknown"
)

func Info() string {
	return fmt.Sprintf("devops-tools %s (commit: %s, built: %s)", Version, GitCommit, BuildDate)
}
