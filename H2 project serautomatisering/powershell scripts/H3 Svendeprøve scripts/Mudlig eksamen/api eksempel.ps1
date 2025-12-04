# URL til et offentligt API
$url = "https://jsonplaceholder.typicode.com/users"

# Send GET request
$response = Invoke-RestMethod -Method GET -Uri $url

# Vis data
$response
