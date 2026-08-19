# Write-PsMdTable


## Example
Create a basic table with the test data provided.

Injest the `data.json` file.

```pwsh
$MyObject = Get-Content .\data.json | ConvertFrom-Json
```
Example output:
```pwsh
$MyObject.Count
32

$MyObject | Select-Object -First 5 | Format-Table

Artist  Release    Album         Type   Year Month Day
------  -------    -----         ----   ---- ----- ---
Madonna 1983-07-27 Madonna       Studio 1983 07    27 
Kylie   1988-07-04 Kylie         Studio 1988 07    04 
Madonna 1984-11-12 Like a Virgin Studio 1984 11    12 
Madonna 1986-06-30 True Blue     Studio 1986 06    30 
Madonna 1989-03-20 Like a Prayer Studio 1989 03    20
```
Filter your data as desired:
```pwsh
# get all 1990s releases
$MyData = $MyObject | Where-Object -FilterScript { $PSItem.Year -ge 1990 -and $PSItem.Year -le 1999 } | Sort-Object -Property Year,Month,Day | Select-Object -Property Artist,Album,Release

$MyData

Artist  Album               Release
------  -----               -------
Kylie   Rhythm of Love      1990-11-12
Kylie   Let's Get to It     1991-10-14
Madonna Erotica             1992-10-19
Kylie   Kylie Minogue       1994-09-19
Madonna Bedtime Stories     1994-10-24
Kylie   Impossible Princess 1997-10-22
Madonna Ray of Light        1998-02-22
```
Convert to a markdown table with columns Release, Artist, and Album:
```pwsh
# 
$Splat = @{
  InputObject = $MyData
  Columns = @('Release','Artist','Album')
  Justification = @('C','R','L')
}
$MyTable = Write-PsMdTable @Splat
```
Your table is now assigned to `$MyTable`:
```pwsh
$MyTable
| Release | Artist | Album |
| :--: | ---: | :--- |
| 1990-11-12 | Kylie | Rhythm of Love |
| 1991-10-14 | Kylie | Let's Get to It |
| 1992-10-19 | Madonna | Erotica |
| 1994-09-19 | Kylie | Kylie Minogue |
| 1994-10-24 | Madonna | Bedtime Stories |
| 1997-10-22 | Kylie | Impossible Princess |
| 1998-02-22 | Madonna | Ray of Light |
```
And your table should look like this in Markdown:

| Release | Artist | Album |
| :--: | ---: | :--- |
| 1990-11-12 | Kylie | Rhythm of Love |
| 1991-10-14 | Kylie | Let's Get to It |
| 1992-10-19 | Madonna | Erotica |
| 1994-09-19 | Kylie | Kylie Minogue |
| 1994-10-24 | Madonna | Bedtime Stories |
| 1997-10-22 | Kylie | Impossible Princess |
| 1998-02-22 | Madonna | Ray of Light |
