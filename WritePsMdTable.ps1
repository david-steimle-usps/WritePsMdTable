function Write-PsMdTable {
  <#
  .SYNOPSIS
  A tool for converting a PowerShell object into a markdown table.
  .DESCRIPTION
  Accepts object input, column names, and column justification to create a basic markdown table from the object. Column selection and justification preferences help build the table more accurately.

  Use `Get-Help Write-PsMdTable -Online` for further examples.
  .EXAMPLE
  $MyObject = @(
    [pscustomobject]@{
      Year = 4
      Name = 'J. Doe'
    },
    [pscustomobject]@{
      Year = 1
      Name = 'A. Newb'
    },[pscustomobject]@{
      Year = 2
      Name = 'C. Yalater'
    }
  )

  Write-PsMdTable -InputObject $MyObject -Columns @('Name','Year') -Justification @('L','C')

  .EXAMPLE
  $Splat = @{
    InputObject = (Get-Content .\data.json | ConvertFrom-Json) | Sort-Object -Property Year,Month,Day
    Columns = @('Release','Type','Artist','Album')
    Justification = @('C','C','R','L')
  }

  Write-PsMdTable @Splat

  .PARAMETER InputObject
  The object for table creation.

  .PARAMETER Columns
  The properties to use as column names in desired order.

  .PARAMETER Justification
  Array of L/C/R (case insensitive) entries for Left/Center/Right justification of columns. Any non-L/C/R or null entry will result in a centered column.

  .INPUTS
  PSObject

  .OUTPUTS
  String

  .LINK
  https://github.com/david-steimle-usps/WritePsMdTable
  #>
  [CmdletBinding()]
  param(
    [Parameter(
      Mandatory = $true,
      ValueFromPipeline = $true,
      HelpMessage = "The object for table creation."
    )]
    [psobject]$InputObject,
    [Parameter(
      Mandatory = $true,
      ValueFromPipeline = $true,
      HelpMessage = "The properties to use as column names in desired order."
    )]
    [array]$Columns,
    [Parameter(
      Mandatory = $false,
      ValueFromPipeline = $true,
      HelpMessage = "Array of L/C/R entries for Left/Center/Right justification of columns."
    )]
    [array]$Justification
  )

  $ColumnDefinitions = New-Object "System.Collections.Generic.List[psobject]"

  $Columns.ForEach({
    $ColumnDefinitions.Add(
      [pscustomobject]@{
        Name = $PSItem
        Length = $(
          if($PSItem.Length -lt 4){
            Write-Output 4
          } else {
            Write-Output $PSItem.Length
          }
        )
        Justification = $Justification[
          [array]::IndexOf($Columns,$PSItem)
        ].ToUpper()
      }
    )
  })

  $TableData = $InputObject | Select-Object -Property $Columns

  foreach($Row in $TableData){
    foreach($Name in $Row.PSObject.Properties.Name){
      $Compare = ($Row.$Name).Length
      $ColDef = $ColumnDefinitions | Where-Object -Property Name -eq $Name
      $DefinedLength = $ColDef | Select-Object -ExpandProperty Length
      Write-Verbose "$Compare | $DefinedLength"
      if($Compare -gt $DefinedLength){
        ($ColumnDefinitions | Where-Object -Property Name -eq $Name).Length = $Compare
      }
    }
  }

  $Table = New-Object "System.Collections.Generic.List[string]"

  $ColumnHeader = "| "
  $Columns.Foreach({
    $Width = ($ColumnDefinitions | Where-Object -Property Name -eq $PSItem).Length
    $ColumnHeader += $PSItem.PadRight($Width)
    $ColumnHeader += " | "
  })
  $Table.Add($ColumnHeader)

  $Justifiers = "| "
  $Columns.Foreach({
    $Width = ($ColumnDefinitions | Where-Object -Property Name -eq $PSItem).Length
    $Justification = ($ColumnDefinitions | Where-Object -Property Name -eq $PSItem).Justification
    $JustificationDef = switch($Justification){
      'L' {
        ":" + ('-' * ($Width -1))
        break
      }
      'R' {
        ('-' * ($Width -1)) + ":"
        break
      }
      default {
        ":" + ('-' * ($Width -2)) + ":"
      }
    }
    $Justifiers += $JustificationDef
    $Justifiers += " | "
  })
  $Table.Add($Justifiers)

  foreach($Row in $TableData){
    foreach($Name in $Row.PSObject.Properties.Name){
      $Width = ($ColumnDefinitions | Where-Object -Property Name -eq $Name).Length
      $Row.$Name = ([string]($Row.$Name)).PadRight($Width)
    }
    $TableRow = "| "
    foreach($Name in $Row.PSObject.Properties.Name){
      $TableRow += $Row.$Name + " | "
    }
    $Table.Add($TableRow)
  }

  $Table
}
