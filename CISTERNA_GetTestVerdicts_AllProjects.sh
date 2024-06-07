## Script to get all the latest test execution results from all projects in a given TestHub server instance

SERVER=<server url>

OFFLINE_TOKEN=<offline token from testhub>

echo Getting Access Token...
ACCESS_TOKEN=$(curl -fsk -X POST $SERVER/rest/tokens/ -H 'Content-Type: application/x-www-form-urlencoded' -d "refresh_token=$OFFLINE_TOKEN" | sed -r -n 's/.*"access_token":"([^"]*)".*/\1/p') && 

# echo Access Token: $ACCESS_TOKEN 

PROJECTS=$(curl -k -X GET -H 'Authorization: Bearer '"$ACCESS_TOKEN"'' -H 'accept: application/json' "$SERVER/rest/projects")

# echo "Projects: $PROJECTS"

# Print project list 
  PROJECTS_LIST=$(echo $PROJECTS | jq -r '.data[]' )

# echo "Projects List: $PROJECTS_LIST"
# echo "Projects: $PROJECTS"

for PROJECT_ID in $(echo $PROJECTS_LIST | jq -r '.id'); do
  # Trim any leading/trailing whitespaces from project ID 
  trimmed_project_id=$(echo "$PROJECT_ID" | tr -d '\r\n')
  DETAILS_URL="$SERVER/rest/projects/$trimmed_project_id/results?reduceByTestOn=startDate.highest"

  # echo Constructed URL --- DETAILS_URL="$DETAILS_URL"

  PROJECT_DETAILS=$(curl -k -X GET -H 'Authorization: Bearer '"$ACCESS_TOKEN"'' -H 'accept: application/json' "$DETAILS_URL")
  echo "-------------------------"
    echo "Project ID: $PROJECT_ID"
  # echo "Details: $PROJECT_DETAILS"
  # echo "Results: $(echo $PROJECT_DETAILS | jq -j '.results[] | "Test: ", .name, ", Started at: ", .startDate, ", Verdict: ", .verdict, "\n"')"
  # Pretty format the date instead of using UTC
    echo "Results: $(echo $PROJECT_DETAILS | jq -j '.results[] | "Test: ", .name, ", Started at: ", (.startDate / 1000 | strftime("%Y-%m-%dT%H:%M:%SZ")), ", Verdict: ", .verdict, "\n"')"
  echo "-------------------------"
done
