package main

import (
	"encoding/csv"
	"errors"
	"flag"
	"fmt"
	"io"
	"os"
	"oss.ac/logc"
	"path"
	"path/filepath"
	"strings"
)

const (
	oldXPath = "./node-benchmark-2024-03-19_09-38.v20.10.0.original"
	oldYPath = "./node-benchmark-2024-03-20_09-23.v21.7.1"
	new1Path = "./node-benchmark-2024-03-14_22-58"
	new2Path = "./node-benchmark-2024-03-16_21-46"
	new3Path = "./node-benchmark-2024-03-17_22-58"
	cX       = "./cX"
	cY       = "./cY"
)

var (
	symbolMapping4OldPath = map[string]string{
		"X": oldXPath,
		"Y": oldYPath,
	}
	symbolMapping4C = map[string]string{
		"X": cX,
		"Y": cY,
	}

	//categories = [...]string{"assert"}
	categories = [...]string{"assert", "async_hooks", "blob", "buffers", "child_process",
		"cluster", "crypto", "dgram", "diagnostics_channel", "dns", "domain", "error", "es", "esm", "events",
		"fs", "http", "http2", "https", "mime", "misc", "module", "napi", "net", "os", "path", "perf_hooks",
		"permission", "policy", "process", "querystring", "readline", "streams", "string_decoder",
		"test_runner", "timers", "tls", "url", "util", "v8", "validators", "vm", "webstreams", "worker", "zlib"}
)

var FailedTest = errors.New("test failed for this category")

func createNonExistDir(dir string) {
	if _, err := os.Stat(dir); err != nil {
		if os.IsNotExist(err) {
			err := os.Mkdir(dir, 0755)
			if err != nil {
				logc.Errorf("error creating directory: %s", err)
			} else {
				logc.Logf("Directory created: %s", dir)
			}
		} else {
			logc.Errorf("error checking directory: %s", err)
		}
	}
}

func parseCSV(dir string) ([][]string, error) {
	retCodeFile, err := os.Open(path.Join(dir, "return.code"))
	if err != nil {
		return nil, err
	}
	defer func(retCodeFile *os.File) {
		err := retCodeFile.Close()
		if err != nil {
			logc.Error(err)
		}
	}(retCodeFile)
	retCode, err := io.ReadAll(retCodeFile)
	if err != nil {
		return nil, err
	}
	if retCode[0] != '0' {
		logc.Error("may fail")
	}

	file := path.Join(dir, "results.txt")
	csvFile, err := os.Open(file)
	if err != nil {
		return nil, err
	}
	defer func(csvFile *os.File) {
		err = csvFile.Close()
		if err != nil {
			logc.Error(err)
		}
	}(csvFile)

	reader := csv.NewReader(csvFile)
	allRecords, err := reader.ReadAll()
	if err != nil {
		return nil, err
	}

	return allRecords, nil
}

func copyRow(binName string, dst []string, src []string) {
	dst[0] = binName
	for i := 0; i < len(src); i++ {
		r := strings.ReplaceAll(src[i], `""`, `'`)
		r = strings.Trim(r, ` `)
		if binName == `"binary"` || i < 2 {
			r = fmt.Sprintf(`"%s"`, r)
		}
		dst[i+1] = r
	}
}

func merge(wd string, sym string) {
	oldDir := path.Join(wd, symbolMapping4OldPath[sym])
	dir := path.Join(wd, symbolMapping4C[sym])
	createNonExistDir(dir)

	for _, c := range categories {
		logc.Logf("merging category '%s' of %s ...", c, sym)
		oldRecords, err := parseCSV(path.Join(oldDir, c))
		if err != nil {
			if errors.Is(err, FailedTest) {
				logc.Errorf("parse CSV error: %s", err)
				continue
			}
			logc.Fatalf("parse CSV error: %s", err)
		}
		newRecords1, err := parseCSV(path.Join(wd, new1Path, c))
		if err != nil {
			logc.Fatalf("parse CSV error: %s", err)
		}
		newRecords2, err := parseCSV(path.Join(wd, new2Path, c))
		if err != nil {
			logc.Fatalf("parse CSV error: %s", err)
		}
		newRecords3, err := parseCSV(path.Join(wd, new3Path, c))
		if err != nil {
			logc.Fatalf("parse CSV error: %s", err)
		}

		var newRecords [][]string
		newRecords = make([][]string, (len(oldRecords)-1)*6+1)
		for i := 0; i < len(newRecords); i++ {
			newRecords[i] = make([]string, len(oldRecords[0])+1)
		}

		iMax := len(oldRecords)
		if iMax < 2 {
			logc.Warnf("skip category :%s", c)
			continue
		}
		newTries := [3][][]string{newRecords1, newRecords2, newRecords3}
		currentItem := ""
		ii := 1
		kk := 0
		nn := 0
		lastIndex := 0
		var config []string
		config = make([]string, 0)
		for i := 0; i <= iMax; i++ {
			if i == 0 {
				copyRow(`"binary"`, newRecords[0], oldRecords[0])
			} else {
				if i < iMax && oldRecords[i][0] == currentItem {
					//logc.Logf("ii: %d, i: %d", ii, i)
					copyRow(`"old"`, newRecords[ii], oldRecords[i])
					//logc.Log(newRecords[ii])
					ii++
					config = append(config, oldRecords[i][1])
				} else {
					// check new category?
					if ii == 1 {
						//logc.Logf("ii: %d, i: %d", ii, i)
						copyRow(`"old"`, newRecords[ii], oldRecords[i])
						//logc.Log(newRecords[ii])
						ii++
						config = append(config, oldRecords[i][1])
						currentItem = oldRecords[i][0]
						lastIndex = 1
					} else {
						// append newRecords{1,2,3}
						if kk < len(newTries) {
							for k := 1; k < len(newTries[kk]); k++ {
								//logc.Log("New: " + newTries[kk][k][0])
								//logc.Log("Cur: " + currentItem)
								if currentItem == newTries[kk][k][0] {
									if nn < len(config) && config[nn] == newTries[kk][k][1] {
										//logc.Logf("ii: %d, i: %d", ii, i)
										copyRow(`"new"`, newRecords[ii], newTries[kk][k])
										//logc.Log(newRecords[ii])
										ii++
									}
									nn++
								}
							}
							kk++
							if kk < len(newTries) {
								// re-loop oldRecords
								i = lastIndex - 1 // i++ in next for statement
							}
						} else {
							// next item
							i-- // sub an additional i++ in last for loop
							//logc.Logf("ii: %d, i: %d", ii, i)
							copyRow(`"old"`, newRecords[ii], oldRecords[i])
							config = make([]string, 0)
							config = append(config, oldRecords[i][1])
							//logc.Log(newRecords[ii])
							ii++
							currentItem = oldRecords[i][0]
							kk = 0
							nn = 0
							lastIndex = i
						}
					}
				}
			}
		}

		// write csv data
		newCSVFilePath := path.Join(dir, c, "results.csv")
		err = os.MkdirAll(filepath.Dir(newCSVFilePath), 0755)
		if err != nil {
			logc.Fatal(err)
		}
		newCSVFile, err := os.Create(newCSVFilePath)
		if err != nil {
			logc.Fatal(err)
		}
		newCSVWriter := csv.NewWriter(newCSVFile)
		err = newCSVWriter.WriteAll(newRecords)
		if err != nil {
			logc.Fatal(err)
		}
		newCSVWriter.Flush()
		func(newCSVFile *os.File) {
			err := newCSVFile.Close()
			if err != nil {
				logc.Error(err)
			}
		}(newCSVFile)
	}
}

func main() {
	currentDir, err := os.Getwd()
	if err != nil {
		logc.Fatal(err)
	}

	dir := flag.Arg(0)
	if dir != "" {
		if _, err := os.Stat(dir); err != nil {
			if os.IsNotExist(err) {
				logc.Fatalf("directory does not exist: %s", dir)
			} else {
				logc.Fatalf("error checking directory: %s", err)
			}
		}
	} else {
		dir = currentDir
	}

	merge(dir, "X")
	merge(dir, "Y")
}
