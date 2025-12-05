function variables {

    $string = "dette er text"
    $int = 5
    $double = 5.5
    $bool = $true
    $array = @("item1", "item2", "item3")

    Write-Host "String: $string"
    Write-Host "Integer: $int"
    Write-Host "Float: $float"
    Write-Host "Boolean: $bool"
    Write-Host "Array: $array"
    Write-Host "First item in array: $($array[0])"

}

function ifStatement {
    $number = 10

    if ($number -gt 5) {
        Write-Host "$number is greater than 5"
    } elseif ($number -eq 5) {
        Write-Host "$number is equal to 5"
    } else {
        Write-Host "$number is less than 5"
    }

}

function doLoopExample {

    do {
        $count = Read-Host "Enter a value"
        Write-Host "Count is $count"

    } while ($count -le 5)
}
function whileLoopExample {
    $count = 1

    while ($count -le 5) {
        Write-Host "Count is $count"
        $count = Read-Host "Enter a new value"
    }
}

function forloopExample {

    for ($i = 1; $i -le 5; $i++) {
        Write-Host "Iteration $i"
    }
}