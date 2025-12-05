
function create_database {
    Import-Module PSSQLite

    # SQL Statement
    $query = @"
CREATE TABLE Users (
    UserID INTEGER PRIMARY KEY AUTOINCREMENT,
    Name TEXT NOT NULL,
    Email TEXT NOT NULL,
    Age INTEGER
);
"@

    Invoke-SqliteQuery -Query $query -DataSource "C:\Users\FMI-C-OSIC80\IdeaProjects\H2-serverautomatisering-\H2 project serautomatisering\powershell scripts\Db.sqlite3"

    Write-Host "SQLite table created!"

}
function insert_data
{
    Import-Module PSSQLite

    $query = @"
INSERT INTO Users (Name, Email, Age) VALUES
('Kris', 'Kris@daddyco.com', 30),
('Maya', 'Maya@daddyco.com', 25),
('Markus', 'Markus@daddyco.com', 28);
"@
    Invoke-SqliteQuery -Query $query -DataSource "C:\Users\FMI-C-OSIC80\IdeaProjects\H2-serverautomatisering-\H2 project serautomatisering\powershell scripts\Db.sqlite3"

    Write-Host "Data inserted into SQLite table!"

}

function get_data {
    Import-Module PSSQLite

    # SQL Statement
    $query = "SELECT * FROM Users;"

    $results = Invoke-SqliteQuery -Query $query -DataSource "C:\Users\FMI-C-OSIC80\IdeaProjects\H2-serverautomatisering-\H2 project serautomatisering\powershell scripts\Db.sqlite3"

    return $results
}







