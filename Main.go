package main

import (
	"encoding/json"
	"fmt"
	"net/http"
	"os"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/dynamodb"
	"github.com/gorilla/mux"

	"github.com/jamespearly/loggly"
)

type DynamoDbEvent struct {
	EventName     string
	ID            string
	VenueName     string
	StartDateTime string
	StartDate     string
	City          string
}

type DynamoDbStatus struct {
	RecordCount int64
	Table       string
}

//handle /all/
func allHandler(w http.ResponseWriter, r *http.Request) {
	fmt.Println("handling all")
	response := getAllEventsFromDynamoDB()
	fmt.Fprintf(w, response)
}

//handle /status/
func statusHandler(w http.ResponseWriter, r *http.Request) {
	fmt.Println("handling status")
	response := getStatusOfDynamoDBtable()
	fmt.Fprintf(w, response)
}

//return json representation of all items in the table
func getAllEventsFromDynamoDB() string {

	sess, err := session.NewSession(&aws.Config{
		Region: aws.String("us-east-1")},
	)
	checkErr("Something went wrong with aws config", err)
	// Create DynamoDB client
	svc := dynamodb.New(sess)
	tableName := "Ticketmaster_events"
	input := &dynamodb.ScanInput{
		TableName: aws.String(tableName),
	}
	result, err := svc.Scan(input)
	checkErr("Error scanning table...", err)
	return result.String()
}

//return the tableName and tablecount
func getStatusOfDynamoDBtable() string {

	sess, err := session.NewSession(&aws.Config{
		Region: aws.String("us-east-1")},
	)
	checkErr("Something went wrong with aws config", err)
	// Create DynamoDB client
	svc := dynamodb.New(sess)
	tableName := "Ticketmaster_events"
	input := &dynamodb.ScanInput{
		TableName: aws.String(tableName),
	}
	result, err := svc.Scan(input)
	count := result.Count
	checkErr("Error scanning table...", err)
	status := DynamoDbStatus{*count, tableName}
	r, err := json.Marshal(status)
	checkErr("cant marshall dynamo db status", err)
	return string(r)
}

func main() {
	fmt.Println("web server started")
	r := mux.NewRouter()
	r.HandleFunc("/chansen/all/", allHandler)
	r.HandleFunc("/chansen/status/", statusHandler)
	http.ListenAndServe(":8080", r)
}

func checkErr(message string, err error) {
	if err != nil {
		client := loggly.New("csc484")
		logglyResp := client.EchoSend("error", message)
		fmt.Println("error:", logglyResp)
		fmt.Println(err)
		os.Exit(1)
	}
}
