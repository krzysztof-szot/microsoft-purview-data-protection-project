[CmdletBinding()]
param(
    [string] $Manifest = (Join-Path $PSScriptRoot '../fixtures/manifest.csv'),
    [string] $Results = (Join-Path $PSScriptRoot '../tests/classification-results.csv')
)

$ErrorActionPreference = 'Stop'
$fixtures = @(Import-Csv -LiteralPath $Manifest)
$observations = @(Import-Csv -LiteralPath $Results)
$runSplits = [ordered]@{
    v1_tuning = 'tuning'
    v2_tuning = 'tuning'
    v2_holdout = 'holdout'
}
$validOutcomes = @('MATCH', 'NO_MATCH', 'PENDING', 'NOT_RUN')

$fixturesById = @{}
foreach ($fixture in $fixtures) {
    if ([string]::IsNullOrWhiteSpace($fixture.fixture_id) -or $fixturesById.ContainsKey($fixture.fixture_id)) {
        throw "Missing or duplicate fixture ID in manifest: '$($fixture.fixture_id)'."
    }
    if ($fixture.split -notin $runSplits.Values -or $fixture.ground_truth -notin @('finance_case', 'near_match', 'neutral')) {
        throw "Invalid split or ground truth for '$($fixture.fixture_id)'."
    }
    $fixturesById[$fixture.fixture_id] = $fixture
}

$resultsByKey = @{}
foreach ($observation in $observations) {
    $id = $observation.fixture_id
    $run = $observation.run_id
    $key = "$run/$id"
    if ([string]::IsNullOrWhiteSpace($run) -or [string]::IsNullOrWhiteSpace($id) -or
        -not $runSplits.Contains($run) -or -not $fixturesById.ContainsKey($id) -or
        $fixturesById[$id].split -ne $runSplits[$run]) {
        throw "Unknown run or fixture, or fixture in the wrong split: '$key'."
    }
    if ($resultsByKey.ContainsKey($key) -or $observation.result -notin $validOutcomes) {
        throw "Duplicate row or invalid result for '$key'."
    }
    $resultsByKey[$key] = $observation.result
}

foreach ($run in $runSplits.Keys) {
    $expected = @($fixtures | Where-Object split -EQ $runSplits[$run])
    if ($expected.Count -eq 0) {
        throw "Manifest has no fixtures for '$run'."
    }

    $counts = @{ TP = 0; FP = 0; FN = 0; TN = 0 }
    $falsePositives = [System.Collections.Generic.List[string]]::new()
    $falseNegatives = [System.Collections.Generic.List[string]]::new()
    $unconfirmed = [System.Collections.Generic.List[string]]::new()
    foreach ($fixture in $expected) {
        $id = $fixture.fixture_id
        $result = $resultsByKey["$run/$id"]
        if ($result -notin @('MATCH', 'NO_MATCH')) {
            $unconfirmed.Add($id)
            continue
        }

        if ($fixture.ground_truth -eq 'finance_case') {
            if ($result -eq 'MATCH') { $counts.TP++ }
            else { $counts.FN++; $falseNegatives.Add($id) }
        }
        else {
            if ($result -eq 'NO_MATCH') { $counts.TN++ }
            else { $counts.FP++; $falsePositives.Add($id) }
        }
    }

    $report = [ordered]@{
        Run = $run
        Confirmed = $expected.Count - $unconfirmed.Count
        Expected = $expected.Count
        TP = $null
        FP = $null
        FN = $null
        TN = $null
        FalsePositiveIds = @()
        FalseNegativeIds = @()
        UnconfirmedIds = $unconfirmed.ToArray()
    }
    if ($unconfirmed.Count -eq 0) {
        foreach ($metric in $counts.Keys) {
            $report[$metric] = $counts[$metric]
        }
        $report.FalsePositiveIds = $falsePositives.ToArray()
        $report.FalseNegativeIds = $falseNegatives.ToArray()
    }
    [pscustomobject] $report
}
