package health

import (
	"fmt"
	"net/http"
	"time"
)

type Check struct {
	Name string
	Run  func() error
}

var defaultChecks = []Check{
	{
		Name: "network",
		Run:  checkNetwork,
	},
}

func RunChecks() error {
	for _, c := range defaultChecks {
		if err := c.Run(); err != nil {
			return fmt.Errorf("check %q: %w", c.Name, err)
		}
	}
	return nil
}

func checkNetwork() error {
	client := &http.Client{Timeout: 5 * time.Second}
	resp, err := client.Get("https://www.google.com")
	if err != nil {
		return err
	}
	resp.Body.Close()
	return nil
}
