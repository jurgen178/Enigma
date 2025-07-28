# Enigma Machine Simulator in PowerShell
# Simulates the historical Enigma encryption machine

class EnigmaRotor {
    [string]$Wiring
    [int]$Position        # Current position (basic setting)
    [int]$RingSetting     # Ring setting (ring position)
    [char]$NotchPosition
    [string]$Name
    
    EnigmaRotor([string]$name, [string]$wiring, [char]$notch) {
        $this.Name = $name
        $this.Wiring = $wiring
        $this.Position = 0
        $this.RingSetting = 0
        $this.NotchPosition = $notch
    }
    
    [char] EncodeForward([char]$letter) {
        [int]$index = [int][char]$letter - [int][char]'A'
        # Ring setting: input shift
        [int]$adjustedIndex = ($index + $this.Position - $this.RingSetting + 26) % 26
        [char]$wireChar = $this.Wiring[$adjustedIndex]
        # Ring setting: output shift
        [int]$outputIndex = ([int][char]$wireChar - [int][char]'A' - $this.Position + $this.RingSetting + 26) % 26
        return [char]([int][char]'A' + $outputIndex)
    }
    
    [char] EncodeBackward([char]$letter) {
        [int]$index = [int][char]$letter - [int][char]'A'
        # Ring setting: backward calculation
        [int]$adjustedIndex = ($index + $this.Position - $this.RingSetting + 26) % 26
        [char]$searchChar = [char]([int][char]'A' + $adjustedIndex)
        [int]$wireIndex = $this.Wiring.IndexOf($searchChar)
        [int]$outputIndex = ($wireIndex - $this.Position + $this.RingSetting + 26) % 26
        return [char]([int][char]'A' + $outputIndex)
    }
    
    [bool] AtNotch() {
        # With direct position setting, check notch against direct position
        [int]$notchPos = [int][char]$this.NotchPosition - [int][char]'A'
        return ($this.Position -eq $notchPos)
    }
    
    [void] Advance() {
        $this.Position = ($this.Position + 1) % 26
    }
    
    [void] SetPosition([char]$position) {
        $this.Position = [int][char]$position - [int][char]'A'
    }
    
    [void] SetRingSetting([char]$ringSetting) {
        $this.RingSetting = [int][char]$ringSetting - [int][char]'A'
    }
}

class EnigmaReflector {
    [string]$Wiring
    [string]$Name
    
    EnigmaReflector([string]$name, [string]$wiring) {
        $this.Name = $name
        $this.Wiring = $wiring
    }
    
    [char] Reflect([char]$letter) {
        [int]$index = [int][char]$letter - [int][char]'A'
        return $this.Wiring[$index]
    }
}

class EnigmaPlugboard {
    [hashtable]$Connections
    
    EnigmaPlugboard() {
        $this.Connections = @{}
    }
    
    [void] AddConnection([char]$letter1, [char]$letter2) {
        $this.Connections[$letter1] = $letter2
        $this.Connections[$letter2] = $letter1
    }
    
    [char] Encode([char]$letter) {
        if ($this.Connections.ContainsKey($letter)) {
            return $this.Connections[$letter]
        }
        return $letter
    }
}

class EnigmaMachine {
    [EnigmaRotor[]]$Rotors
    [EnigmaRotor[]]$AvailableRotors
    [EnigmaReflector]$Reflector
    [EnigmaPlugboard]$Plugboard
    
    EnigmaMachine() {
        # All 5 Enigma I rotors (historically correct wirings)
        [EnigmaRotor]$rotor1 = [EnigmaRotor]::new("I", "EKMFLGDQVZNTOWYHXUSPAIBRCJ", 'Q')
        [EnigmaRotor]$rotor2 = [EnigmaRotor]::new("II", "AJDKSIRUXBLHWTMCQGZNPYFVOE", 'E')
        [EnigmaRotor]$rotor3 = [EnigmaRotor]::new("III", "BDFHJLCPRTXVZNYEIWGAKMUSQO", 'V')
        [EnigmaRotor]$rotor4 = [EnigmaRotor]::new("IV", "ESOVPZJAYQUIRHXLNFTGKDCMWB", 'J')
        [EnigmaRotor]$rotor5 = [EnigmaRotor]::new("V", "VZBRGITYUPSDNHLXAWMJQOFECK", 'Z')
        
        # Default configuration: rotors III, II, I (from left to right)
        $this.Rotors = @($rotor3, $rotor2, $rotor1)  # Right to left
        
        # Store all available rotors for swapping
        $this.AvailableRotors = @($rotor1, $rotor2, $rotor3, $rotor4, $rotor5)
        
        # Default reflector B
        $this.Reflector = [EnigmaReflector]::new("B", "YRUHQSLDPXNGOKMIEBFZCWVJAT")
        
        $this.Plugboard = [EnigmaPlugboard]::new()
    }
    
    [void] SetRotorPositions([string]$positions) {
        # Apply positions from right to left
        for ([int]$i = 0; $i -lt [Math]::Min($positions.Length, $this.Rotors.Length); $i++) {
            [int]$reversedIndex = $positions.Length - 1 - $i
            $this.Rotors[$i].SetPosition($positions[$reversedIndex])
        }
    }
    
    [void] SetRingSettings([string]$ringSettings) {
        # Apply ring settings from right to left
        for ([int]$i = 0; $i -lt [Math]::Min($ringSettings.Length, $this.Rotors.Length); $i++) {
            [int]$reversedIndex = $ringSettings.Length - 1 - $i
            $this.Rotors[$i].SetRingSetting($ringSettings[$reversedIndex])
        }
    }
    
    [void] AddPlugboardConnection([char]$letter1, [char]$letter2) {
        $this.Plugboard.AddConnection($letter1, $letter2)
    }
    
    [void] SetRotorConfiguration([int]$leftRotor, [int]$middleRotor, [int]$rightRotor) {
        if ($leftRotor -ge 1 -and $leftRotor -le 5 -and 
            $middleRotor -ge 1 -and $middleRotor -le 5 -and 
            $rightRotor -ge 1 -and $rightRotor -le 5) {
            
            $this.Rotors[0] = $this.AvailableRotors[$rightRotor - 1]   # Right
            $this.Rotors[1] = $this.AvailableRotors[$middleRotor - 1] # Middle  
            $this.Rotors[2] = $this.AvailableRotors[$leftRotor - 1]   # Left
            
            # Reset positions and ring settings
            foreach ($rotor in $this.Rotors) {
                $rotor.Position = 0
                $rotor.RingSetting = 0
            }
        }
    }
    
    [char] EncodeCharacter([char]$letter) {
        # Convert to uppercase
        [char]$letter = [char]::ToUpper($letter)
        
        # Only process letters
        if ($letter -lt 'A' -or $letter -gt 'Z') {
            return $letter
        }
        
        # Rotor movement BEFORE encryption (historical timing)
        $this.AdvanceRotors()
        
        # Through plugboard
        [char]$encoded = $this.Plugboard.Encode($letter)
        
        # Through rotors (forward)
        for ([int]$i = 0; $i -lt $this.Rotors.Length; $i++) {
            $encoded = $this.Rotors[$i].EncodeForward($encoded)
        }
        
        # Through reflector
        $encoded = $this.Reflector.Reflect($encoded)
        
        # Through rotors (backward)
        for ([int]$i = $this.Rotors.Length - 1; $i -ge 0; $i--) {
            $encoded = $this.Rotors[$i].EncodeBackward($encoded)
        }
        
        # Through plugboard (again)
        $encoded = $this.Plugboard.Encode($encoded)
        
        return $encoded
    }
    
    [void] AdvanceRotors() {
        # Standard Enigma double-stepping mechanism
        if ($this.Rotors[1].AtNotch()) {
            # Middle rotor is at notch - double stepping occurs
            $this.Rotors[1].Advance()
            $this.Rotors[2].Advance()
        }
        elseif ($this.Rotors[0].AtNotch()) {
            # Right rotor is at notch - middle rotor advances
            $this.Rotors[1].Advance()
        }
        
        # Right rotor always advances
        $this.Rotors[0].Advance()
    }
    
    [string] EncodeMessage([string]$message) {
        [string]$result = ""
        foreach ($char in $message.ToCharArray()) {
            $result += $this.EncodeCharacter($char)
        }
        return $result
    }
}

# Main function for Enigma encryption
function Invoke-EnigmaEncryption {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Text,
        
        [Parameter(Mandatory=$false)]
        [int[]]$RotorConfiguration = @(3, 2, 1),  # Default: III, II, I (Left-Middle-Right)
        
        [Parameter(Mandatory=$false)]
        [string]$RotorPositions = "AAA",  # Basic settings of the rotors (visible positions)
        
        [Parameter(Mandatory=$false)]
        [string]$RingSettings = "AAA",    # Ring settings of the rotors (ring position)
        
        [Parameter(Mandatory=$false)]
        [string]$PlugboardConnections = ""  # Plugboard connections e.g. "AB CD EF"
    )
    
    # Create Enigma machine
    [EnigmaMachine]$enigma = [EnigmaMachine]::new()
    
    # Set rotor configuration
    if ($RotorConfiguration.Length -eq 3) {
        $enigma.SetRotorConfiguration($RotorConfiguration[0], $RotorConfiguration[1], $RotorConfiguration[2])
    }
    
    # Set ring settings (ring position) - FIRST!
    $enigma.SetRingSettings($RingSettings.ToUpper())
    
    # Set rotor positions (basic setting) - AFTER ring settings
    $enigma.SetRotorPositions($RotorPositions.ToUpper())
    
    # Set plugboard connections
    if ($PlugboardConnections) {
        [string[]]$connections = $PlugboardConnections -split '\s+'
        foreach ($connection in $connections) {
            if ($connection.Length -eq 2) {
                $enigma.AddPlugboardConnection([char]$connection[0], [char]$connection[1])
            }
        }
    }
    
    # Encrypt/decrypt text
    [string]$cleanText = $Text.ToUpper() -replace '\s', ''  # Remove spaces
    [string]$result = $enigma.EncodeMessage($cleanText)
    
    # Split into 5-character groups with 10 groups per line (historically correct)
    [string]$formattedResult = ""
    [int]$groupCount = 0
    for ([int]$i = 0; $i -lt $result.Length; $i += 5) {
        if ($i -gt 0) { 
            if ($groupCount -eq 10) {
                $formattedResult += "`n"
                $groupCount = 0
            } else {
                $formattedResult += " "
            }
        }
        $formattedResult += $result.Substring($i, [Math]::Min(5, $result.Length - $i))
        $groupCount++
    }
    
    return $formattedResult
}

# Examples for Invoke-EnigmaEncryption

# https://cryptii.com/pipes/enigma-machine


# Standard
[hashtable]$Standard = @{
    RotorConfiguration = @(1, 2, 3) 
    RotorPositions = "AAA"
    RingSettings = "AAA"
    PlugboardConnections = "AB CD EF GH IJ KL MN OP QR ST"
}

# Kriegsmarine komplex
[hashtable]$Marine1943 = @{
    RotorConfiguration = @(5, 4, 3)    # V-IV-III
    RotorPositions = "BLA"             # U-boat call sign
    RingSettings = "AJD"               # Ring setting
    PlugboardConnections = "AB CD EF GH IJ KL MN OP QR ST"
}

[hashtable]$test = @{
    RotorConfiguration = @(1, 2, 3)
    RotorPositions = "ABC"
    RingSettings = "XYZ"
    PlugboardConnections = "AB CD"
}

Write-Host
[string]$encrypted = Invoke-EnigmaEncryption -Text @"
ENIGMA CHALLENGE
"@ @Standard
[string]$decrypted = Invoke-EnigmaEncryption -Text $encrypted @Standard
Write-Host "Encrypted: $encrypted"  # FYCLD YEKEA BAXXW
Write-Host "Decrypted: $decrypted"  # ENIGM ACHAL LENGE
