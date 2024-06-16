package main

// TODO WIP clean this up

import (
	"encoding/base64"
	"log"
	"os"
	"strings"

	"code.gitea.io/sdk/gitea"
	"gopkg.in/yaml.v2"
)

type Organization struct {
	Name        string
	Description string
}

type Repository struct {
	Name    string
	Owner   string
	Private bool
	Migrate struct {
		Source string
		Mirror bool
	}
}
type File struct {
	Path   string
	Owner  string
	Repo   string
	Branch string
}

type Replacefile struct {
	SourcePath string
	DestPath   string
	Owner      string
	Repo       string
	Branch     string
}

type Config struct {
	Organizations []Organization
	Repositories  []Repository
	Files         []File
	Replacefile   []Replacefile
}

func main() {
	data, err := os.ReadFile("./config.yaml")

	if err != nil {
		log.Fatalf("Unable to read config file: %v", err)
	}

	config := Config{}

	err = yaml.Unmarshal([]byte(data), &config)

	if err != nil {
		log.Fatalf("error: %v", err)
	}

	gitea_host := os.Getenv("GITEA_HOST")
	gitea_user := os.Getenv("GITEA_USER")
	gitea_password := os.Getenv("GITEA_PASSWORD")

	options := (gitea.SetBasicAuth(gitea_user, gitea_password))
	client, err := gitea.NewClient(gitea_host, options)

	if err != nil {
		log.Fatal(err)
	}

	for _, org := range config.Organizations {
		_, _, err = client.CreateOrg(gitea.CreateOrgOption{
			Name:        org.Name,
			Description: org.Description,
		})

		if err != nil {
			log.Printf("Create organization %s: %v", org.Name, err)
		}
	}

	for _, repo := range config.Repositories {
		if repo.Migrate.Source != "" {
			_, _, err = client.MigrateRepo(gitea.MigrateRepoOption{
				RepoName:       repo.Name,
				RepoOwner:      repo.Owner,
				CloneAddr:      repo.Migrate.Source,
				Service:        gitea.GitServicePlain,
				Mirror:         repo.Migrate.Mirror,
				Private:        repo.Private,
				MirrorInterval: "10m",
			})

			if err != nil {
				log.Printf("Migrate %s/%s: %v", repo.Owner, repo.Name, err)
			}
		} else {
			_, _, err = client.AdminCreateRepo(repo.Owner, gitea.CreateRepoOption{
				Name: repo.Name,
				// Description: "TODO",
				Private: repo.Private,
			})
			if err != nil {
				log.Printf("Create %s/%s: %v", repo.Owner, repo.Name, err)
			}
		}
	}
	log.Printf("Updating Files")
	for _, file := range config.Files {
		log.Printf("Config: Path=%s, Branch=%s, Owner=%s, Repo=%s", file.Path, file.Branch, file.Owner, file.Repo)
		contentsResponse, _, err := client.GetContents(file.Owner, file.Repo, file.Branch, file.Path)
		if err != nil {
			log.Printf("Get File For Update %s/%s: %v", file.Repo, file.Path, err)
		}
		updatedContent := strings.Replace(*contentsResponse.Content, "https://github.com/Cal3165/homelab", "http://gitea-http.gitea:3000/ops/homelab", -1)
		updateOptions := gitea.UpdateFileOptions{
			SHA:     contentsResponse.SHA,
			Content: base64.StdEncoding.EncodeToString([]byte(updatedContent)),
		}
		_, _, err = client.UpdateFile(file.Owner, file.Repo, file.Path, updateOptions)
		if err != nil {
			log.Printf("Update File %s/%s: %v", file.Repo, file.Path, err)
		}
	}
	log.Printf("Replace Old Config")
	for _, file := range config.Replacefile {
		log.Printf("Config: SourcePath=%s, DestPath=%s Branch=%s, Owner=%s, Repo=%s", file.SourcePath, file.DestPath, file.Branch, file.Owner, file.Repo)
		// Get the content of the source file
		sourceContents, _, err := client.GetFile(file.Owner, file.Repo, file.Branch, file.SourcePath)
		if err != nil {
			log.Printf("Get Original File For Replace %s/%s: %v", file.Repo, file.SourcePath, err)
		}

		// Get the SHA of the target file
		targetContents, _, err := client.GetContents(file.Owner, file.Repo, file.Branch, file.DestPath)
		if err != nil {
			log.Printf("Get New File For Replace %s/%s: %v", file.Repo, file.DestPath, err)
		}

		// Update the target file with the content of the source file
		updateOptions := gitea.UpdateFileOptions{
			SHA:     targetContents.SHA,
			Content: base64.StdEncoding.EncodeToString(sourceContents),
		}
		_, _, err = client.UpdateFile(file.Owner, file.Repo, file.DestPath, updateOptions)
		if err != nil {
			log.Printf("Replace File %s/%s: %v", file.Repo, file.DestPath, err)
		}

	}

}
