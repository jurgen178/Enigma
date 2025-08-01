# Enigma Machine Test Script with Historic Data
# Tests the Enigma implementation against known historic configurations and results

# Import the Enigma script
. "$PSScriptRoot\enigma.ps1"

# Test results tracking
$global:TestResults = @()

function Test-EnigmaConfiguration {
    param(
        [string]$TestName,
        [string]$OriginalText,
        [string]$ExpectedEncoded,
        [hashtable]$Configuration,
        [string]$Description = ""
    )
    
    Write-Host "`n=== $TestName ===" -ForegroundColor Cyan
    Write-Host "Description: $Description" -ForegroundColor Gray
    Write-Host "Original: $OriginalText" -ForegroundColor White
    Write-Host "Expected: $ExpectedEncoded" -ForegroundColor Yellow
    
    try {
        # Encrypt the original text
        $actualEncoded = Invoke-EnigmaEncryption -Text $OriginalText @Configuration
        
        # Remove spaces for comparison
        $actualClean = $actualEncoded -replace '\s', ''
        $expectedClean = $ExpectedEncoded -replace '\s', ''
        
        Write-Host "Actual:   $actualEncoded" -ForegroundColor Green
        
        $encryptionPassed = $actualClean -eq $expectedClean
        
        if ($encryptionPassed) {
            Write-Host "✓ Encryption PASSED" -ForegroundColor Green
        } else {
            Write-Host "✗ Encryption FAILED" -ForegroundColor Red
            Write-Host "  Expected: $expectedClean" -ForegroundColor Red
            Write-Host "  Actual:   $actualClean" -ForegroundColor Red
        }
        
        # Test decryption (Enigma is symmetric)
        $decrypted = Invoke-EnigmaEncryption -Text $actualEncoded @Configuration
        $decryptedClean = $decrypted -replace '\s', ''
        $originalClean = $OriginalText.ToUpper() -replace '\s', ''
        
        $decryptionPassed = $decryptedClean -eq $originalClean
        
        if ($decryptionPassed) {
            Write-Host "✓ Decryption PASSED" -ForegroundColor Green
        } else {
            Write-Host "✗ Decryption FAILED" -ForegroundColor Red
            Write-Host "  Original: $originalClean" -ForegroundColor Red
            Write-Host "  Decrypted: $decryptedClean" -ForegroundColor Red
        }
        
        $testPassed = $encryptionPassed -and $decryptionPassed
        
    } catch {
        Write-Host "✗ Test ERROR: $_" -ForegroundColor Red
        $testPassed = $false
        $encryptionPassed = $false
        $decryptionPassed = $false
    }
    
    # Record test result
    $global:TestResults += [PSCustomObject]@{
        TestName = $TestName
        EncryptionPassed = $encryptionPassed
        DecryptionPassed = $decryptionPassed
        OverallPassed = $testPassed
        Configuration = $Configuration
    }
    
    return $testPassed
}

Write-Host "ENIGMA MACHINE HISTORIC VALIDATION TESTS" -ForegroundColor Magenta
Write-Host "=========================================" -ForegroundColor Magenta

# Test 1: Basic functionality without plugboard
Test-EnigmaConfiguration -TestName "Test 1: Basic Enigma" -OriginalText "HELLO" -ExpectedEncoded "MFNCZ" -Configuration @{
    RotorConfiguration = @(3, 2, 1)  # III-II-I
    RotorPositions = "AAA"
    RingSettings = "AAA"
    PlugboardConnections = ""
} -Description "Basic Enigma I configuration, no plugboard connections"

# Test 2: With rotor positions
Test-EnigmaConfiguration -TestName "Test 2: Rotor Positions" -OriginalText "HELLO" -ExpectedEncoded "CAAVL" -Configuration @{
    RotorConfiguration = @(3, 2, 1)  # III-II-I
    RotorPositions = "QWE"
    RingSettings = "AAA"
    PlugboardConnections = ""
} -Description "With initial rotor positions QWE"

# Test 3: Historic Wehrmacht 1940 configuration
Test-EnigmaConfiguration -TestName "Test 3: Wehrmacht 1940" -OriginalText "ATTACKATDAWN" -ExpectedEncoded "KDUWK APQPK JM" -Configuration @{
    RotorConfiguration = @(2, 1, 3)  # II-I-III
    RotorPositions = "QWE"
    RingSettings = "AAA"
    PlugboardConnections = "AR GK OX BP CN IT"
} -Description "Historic Wehrmacht configuration from 1940"

# Test 4: U-Boat configuration (complex)
Test-EnigmaConfiguration -TestName "Test 4: U-Boat Marine" -OriginalText "UBOOTWAFFE" -ExpectedEncoded "QYXFY GNUOD" -Configuration @{
    RotorConfiguration = @(5, 2, 4)  # V-II-IV
    RotorPositions = "BLA"
    RingSettings = "AJD"
    PlugboardConnections = "AZ BF EQ GT HJ KW MS OY PX UV"
} -Description "Kriegsmarine U-Boat configuration 1943"

# Test 5: Known cryptii.com test case
Test-EnigmaConfiguration -TestName "Test 5: Cryptii Reference" -OriginalText "ENIGMA" -ExpectedEncoded "FQGAH W" -Configuration @{
    RotorConfiguration = @(1, 2, 3)  # I-II-III
    RotorPositions = "AAA"
    RingSettings = "AAA"
    PlugboardConnections = ""
} -Description "Reference test case from cryptii.com"

# Test 6: Ring settings effect
Test-EnigmaConfiguration -TestName "Test 6: Ring Settings" -OriginalText "TESTMESSAGE" -ExpectedEncoded "KCIOW DYNGJ V" -Configuration @{
    RotorConfiguration = @(3, 2, 1)  # III-II-I
    RotorPositions = "AAA"
    RingSettings = "XYZ"
    PlugboardConnections = ""
} -Description "Testing the effect of ring settings XYZ"

# Test 7: Historical Operation Barbarossa
Test-EnigmaConfiguration -TestName "Test 7: Operation Barbarossa" -OriginalText "OPERATIONBARBAROSSA" -ExpectedEncoded "LRWNS WLUXD UEQWI UUFB" -Configuration @{
    RotorConfiguration = @(3, 1, 4)  # III-I-IV
    RotorPositions = "JUN"  # June 1941
    RingSettings = "BER"    # Berlin
    PlugboardConnections = "AD CN ET FL GI JV KZ PU QY WX"
} -Description "Approximated settings for Operation Barbarossa communications"

# Test 8: Long message test
Test-EnigmaConfiguration -TestName "Test 8: Long Message" -OriginalText "THEQUICKBROWNFOXJUMPSOVERTHELAZYDOG" -ExpectedEncoded "XCBHK DWLWH ETANR WSXOA QRNCP SLBHD ENZYJ" -Configuration @{
    RotorConfiguration = @(1, 3, 2)  # I-III-II
    RotorPositions = "ABC"
    RingSettings = "DEF"
    PlugboardConnections = "AB CD EF GH IJ KL"
} -Description "Testing with a longer message to verify rotor stepping"

# Test 9: Double stepping test
Test-EnigmaConfiguration -TestName "Test 9: Double Stepping" -OriginalText "AAAA" -ExpectedEncoded "OZDM" -Configuration @{
    RotorConfiguration = @(3, 2, 1)  # III-II-I
    RotorPositions = "ADT"  # Set up for double stepping (II has notch at E)
    RingSettings = "AAA"
    PlugboardConnections = ""
} -Description "Testing the famous Enigma double-stepping mechanism"

# Test 10: Maximum plugboard connections
Test-EnigmaConfiguration -TestName "Test 10: Max Plugboard" -OriginalText "MAXIMUMPLUGBOARD" -ExpectedEncoded "TCHUQ SNQSG YOSMS X" -Configuration @{
    RotorConfiguration = @(4, 5, 1)  # IV-V-I
    RotorPositions = "XYZ"
    RingSettings = "ABC"
    PlugboardConnections = "AB CD EF GH IJ KL MN OP QR ST"  # 10 pairs (maximum historical)
} -Description "Testing with maximum number of plugboard connections (20 letters)"

# Summary
Write-Host "`n" -NoNewline
Write-Host "TEST SUMMARY" -ForegroundColor Magenta
Write-Host "============" -ForegroundColor Magenta

$totalTests = $global:TestResults.Count
$passedTests = ($global:TestResults | Where-Object { $_.OverallPassed }).Count
$encryptionPassed = ($global:TestResults | Where-Object { $_.EncryptionPassed }).Count
$decryptionPassed = ($global:TestResults | Where-Object { $_.DecryptionPassed }).Count

Write-Host "Total Tests: $totalTests" -ForegroundColor White
Write-Host "Overall Passed: $passedTests / $totalTests" -ForegroundColor $(if($passedTests -eq $totalTests) { "Green" } else { "Red" })
Write-Host "Encryption Passed: $encryptionPassed / $totalTests" -ForegroundColor $(if($encryptionPassed -eq $totalTests) { "Green" } else { "Red" })
Write-Host "Decryption Passed: $decryptionPassed / $totalTests" -ForegroundColor $(if($decryptionPassed -eq $totalTests) { "Green" } else { "Red" })

if ($passedTests -eq $totalTests) {
    Write-Host "`n🎉 ALL TESTS PASSED! Enigma implementation is working correctly." -ForegroundColor Green
} else {
    Write-Host "`n❌ Some tests failed. Check the implementation." -ForegroundColor Red
    
    # Show failed tests
    $failedTests = $global:TestResults | Where-Object { -not $_.OverallPassed }
    if ($failedTests) {
        Write-Host "`nFailed Tests:" -ForegroundColor Red
        foreach ($test in $failedTests) {
            Write-Host "  - $($test.TestName)" -ForegroundColor Red
        }
    }
}

# Performance test
Write-Host "`nPERFORMANCE TEST" -ForegroundColor Magenta
Write-Host "================" -ForegroundColor Magenta

$longText = "THE QUICK BROWN FOX JUMPS OVER THE LAZY DOG " * 10  # ~430 characters
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

$result = Invoke-EnigmaEncryption -Text $longText -RotorConfiguration @(3, 2, 1) -RotorPositions "ABC" -RingSettings "DEF" -PlugboardConnections "AB CD EF GH"

$stopwatch.Stop()
Write-Host "Encrypted $($longText.Length) characters in $($stopwatch.ElapsedMilliseconds) ms" -ForegroundColor Green
Write-Host "Rate: $([math]::Round($longText.Length / $stopwatch.Elapsed.TotalSeconds, 0)) characters/second" -ForegroundColor Green

Write-Host "`nTest script completed. Check results above." -ForegroundColor Cyan
