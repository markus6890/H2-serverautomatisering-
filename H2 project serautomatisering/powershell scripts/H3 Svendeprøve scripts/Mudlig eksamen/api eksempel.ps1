# URL til et offentligt API
$url = "https://jsonplaceholder.typicode.com/users"

# Send GET request
$response = Invoke-RestMethod -Method Get -Uri $url

# Vis data
$response
