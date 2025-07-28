# Enigma Machine Simulator in PowerShell
# Simulates the historical Enigma encryption machine used during WWII
# This implementation includes all key components: rotors, reflector, and plugboard
# with historically accurate wiring and mechanics

# Represents a single Enigma rotor with its wiring, position, and ring setting
# Each rotor has:
# - Fixed internal wiring that scrambles letters
# - A position that changes with each keystroke (basic setting)
# - A ring setting that affects the internal offset
# - A notch position that triggers the next rotor to advance
class EnigmaRotor {
    [string]$Wiring        # The scrambling pattern for this rotor (26 characters)
    [int]$Position         # Current rotational position (0-25, corresponds to A-Z)
    [int]$RingSetting      # Ring setting offset (0-25, corresponds to A-Z)
    [char]$NotchPosition   # Letter position where this rotor triggers the next rotor
    [string]$Name          # Roman numeral identifier (I, II, III, IV, V)
    
    # Constructor: Initialize a rotor with its historical specifications
    # Parameters:
    #   $name: Roman numeral identifier (I-V)
    #   $wiring: 26-character string defining the internal scrambling
    #   $notch: Letter where this rotor causes the next rotor to advance
    EnigmaRotor([string]$name, [string]$wiring, [char]$notch) {
        $this.Name = $name
        $this.Wiring = $wiring
        $this.Position = 0        # Start at position A (0)
        $this.RingSetting = 0     # Start with no ring offset
        $this.NotchPosition = $notch
    }
    
    # Encode a letter going forward through the rotor (right to left)
    # This simulates the electrical path from the keyboard through the rotor
    # The ring setting affects both input and output to maintain proper alignment
    [char] EncodeForward([char]$letter) {
        # Convert letter to numerical index (A=0, B=1, ..., Z=25)
        [int]$index = [int][char]$letter - [int][char]'A'
        
        # Apply ring setting: adjust input position relative to rotor position
        # The +26 ensures we never get negative values when using modulo
        [int]$adjustedIndex = ($index + $this.Position - $this.RingSetting + 26) % 26
        
        # Look up the scrambled letter at this position in the rotor wiring
        [char]$wireChar = $this.Wiring[$adjustedIndex]
        
        # Apply ring setting to output: convert back to external position
        # This ensures the ring setting affects the final output correctly
        [int]$outputIndex = ([int][char]$wireChar - [int][char]'A' - $this.Position + $this.RingSetting + 26) % 26
        return [char]([int][char]'A' + $outputIndex)
    }
    
    # Encode a letter going backward through the rotor (left to right)
    # This simulates the return path after reflection, requiring reverse lookup
    # We must find which input position produces the given output
    [char] EncodeBackward([char]$letter) {
        # Convert letter to numerical index
        [int]$index = [int][char]$letter - [int][char]'A'
        
        # Apply ring setting to find the internal rotor position
        [int]$adjustedIndex = ($index + $this.Position - $this.RingSetting + 26) % 26
        
        # Convert back to character for searching in the wiring
        [char]$searchChar = [char]([int][char]'A' + $adjustedIndex)
        
        # Reverse lookup: find where this character appears in the wiring
        # This gives us the input position that would produce this output
        [int]$wireIndex = $this.Wiring.IndexOf($searchChar)
        
        # Apply ring setting to convert back to external position
        [int]$outputIndex = ($wireIndex - $this.Position + $this.RingSetting + 26) % 26
        return [char]([int][char]'A' + $outputIndex)
    }
    
    # Check if this rotor is at its notch position
    # When a rotor reaches its notch, it causes the next rotor to advance
    # This implements the famous "double-stepping" behavior of Enigma
    [bool] AtNotch() {
        # Convert the notch character to numerical position
        [int]$notchPos = [int][char]$this.NotchPosition - [int][char]'A'
        # Check if current position matches the notch position
        return ($this.Position -eq $notchPos)
    }
    
    # Advance the rotor by one position (A->B, B->C, ..., Z->A)
    # This happens with each keystroke according to Enigma mechanics
    [void] Advance() {
        $this.Position = ($this.Position + 1) % 26
    }
    
    # Set the visible rotor position (the basic setting)
    # This is what the operator would see through the rotor window
    [void] SetPosition([char]$position) {
        $this.Position = [int][char]$position - [int][char]'A'
    }
    
    # Set the ring setting (Ringstellung)
    # This internal offset affects the relationship between rotor position and wiring
    [void] SetRingSetting([char]$ringSetting) {
        $this.RingSetting = [int][char]$ringSetting - [int][char]'A'
    }
}

# Represents the Enigma reflector (Umkehrwalze)
# The reflector ensures that Enigma is reciprocal (encoding = decoding)
# It connects pairs of letters, so if A maps to M, then M maps back to A
# This component sits at the end of the rotor stack and sends signals back
class EnigmaReflector {
    [string]$Wiring       # 26-character string defining letter pair connections
    [string]$Name         # Reflector identifier (usually B or C)
    
    # Constructor: Initialize reflector with its wiring pattern
    EnigmaReflector([string]$name, [string]$wiring) {
        $this.Name = $name
        $this.Wiring = $wiring
    }
    
    # Reflect a letter back through the system
    # This is where the signal reverses direction in the Enigma machine
    # The reflector ensures that encryption and decryption are the same operation
    [char] Reflect([char]$letter) {
        # Convert to index and look up the reflected letter
        [int]$index = [int][char]$letter - [int][char]'A'
        return $this.Wiring[$index]
    }
}

# Represents the Enigma plugboard (Steckerbrett)
# This was an additional security feature allowing operators to swap letter pairs
# Up to 10 pairs could be connected, providing extra scrambling before and after the rotors
# If a letter isn't plugged, it passes through unchanged
class EnigmaPlugboard {
    [hashtable]$Connections    # Hash table storing bidirectional letter swaps
    
    # Constructor: Initialize empty plugboard
    EnigmaPlugboard() {
        $this.Connections = @{}
    }
    
    # Add a bidirectional connection between two letters
    # If A is connected to B, then B is automatically connected to A
    # This simulates the physical plugboard cables
    [void] AddConnection([char]$letter1, [char]$letter2) {
        $this.Connections[$letter1] = $letter2
        $this.Connections[$letter2] = $letter1
    }
    
    # Encode a letter through the plugboard
    # If the letter has a plug connection, return the connected letter
    # Otherwise, return the letter unchanged
    [char] Encode([char]$letter) {
        if ($this.Connections.ContainsKey($letter)) {
            return $this.Connections[$letter]
        }
        return $letter
    }
}

# Main Enigma Machine class that coordinates all components
# This represents the complete Enigma machine with its full encryption process:
# Plugboard -> Rotors (forward) -> Reflector -> Rotors (backward) -> Plugboard
class EnigmaMachine {
    [EnigmaRotor[]]$Rotors           # Array of 3 rotors (right, middle, left)
    [EnigmaRotor[]]$AvailableRotors  # All 5 rotors available for selection
    [EnigmaReflector]$Reflector      # The reflector component
    [EnigmaPlugboard]$Plugboard      # The plugboard component
    
    # Constructor: Set up Enigma machine with historical default configuration
    EnigmaMachine() {
        # Create all 5 historically accurate Enigma I rotors
        # Each rotor has unique wiring and notch position based on actual German specifications
        [EnigmaRotor]$rotor1 = [EnigmaRotor]::new("I", "EKMFLGDQVZNTOWYHXUSPAIBRCJ", 'Q')
        [EnigmaRotor]$rotor2 = [EnigmaRotor]::new("II", "AJDKSIRUXBLHWTMCQGZNPYFVOE", 'E')
        [EnigmaRotor]$rotor3 = [EnigmaRotor]::new("III", "BDFHJLCPRTXVZNYEIWGAKMUSQO", 'V')
        [EnigmaRotor]$rotor4 = [EnigmaRotor]::new("IV", "ESOVPZJAYQUIRHXLNFTGKDCMWB", 'J')
        [EnigmaRotor]$rotor5 = [EnigmaRotor]::new("V", "VZBRGITYUPSDNHLXAWMJQOFECK", 'Z')
        
        # Set default rotor configuration: III-II-I (left to right, as historically common)
        # Stored right to left in array for easier processing
        $this.Rotors = @($rotor3, $rotor2, $rotor1)  # Index 0=rightmost, 2=leftmost
        
        # Store all rotors for configuration changes
        $this.AvailableRotors = @($rotor1, $rotor2, $rotor3, $rotor4, $rotor5)
        
        # Set up the standard Reflector B (most commonly used)
        # This wiring ensures that A<->Y, B<->R, etc.
        $this.Reflector = [EnigmaReflector]::new("B", "YRUHQSLDPXNGOKMIEBFZCWVJAT")
        
        # Initialize empty plugboard
        $this.Plugboard = [EnigmaPlugboard]::new()
    }
    
    # Set the visible rotor positions (Grundstellung - basic setting)
    # This is what the operator sees through the rotor windows
    # Positions are applied from right to left to match physical layout
    [void] SetRotorPositions([string]$positions) {
        # Apply positions from right to left to match rotor array indexing
        for ([int]$i = 0; $i -lt [Math]::Min($positions.Length, $this.Rotors.Length); $i++) {
            # Reverse the position string to apply rightmost position to index 0
            [int]$reversedIndex = $positions.Length - 1 - $i
            $this.Rotors[$i].SetPosition($positions[$reversedIndex])
        }
    }
    
    # Set the ring settings (Ringstellung)
    # These internal offsets affect the relationship between rotor position and notch timing
    # Ring settings are also applied from right to left
    [void] SetRingSettings([string]$ringSettings) {
        # Apply ring settings from right to left to match rotor array indexing
        for ([int]$i = 0; $i -lt [Math]::Min($ringSettings.Length, $this.Rotors.Length); $i++) {
            # Reverse the setting string to apply rightmost setting to index 0
            [int]$reversedIndex = $ringSettings.Length - 1 - $i
            $this.Rotors[$i].SetRingSetting($ringSettings[$reversedIndex])
        }
    }
    
    # Add a plugboard connection between two letters
    # This simulates inserting a cable between two plugboard sockets
    [void] AddPlugboardConnection([char]$letter1, [char]$letter2) {
        $this.Plugboard.AddConnection($letter1, $letter2)
    }
    
    # Configure which rotors are installed in the machine
    # Parameters specify rotors from left to right (1-5 corresponding to I-V)
    # This simulates the operator selecting and installing physical rotors
    [void] SetRotorConfiguration([int]$leftRotor, [int]$middleRotor, [int]$rightRotor) {
        # Validate rotor numbers (must be 1-5 for rotors I-V)
        if ($leftRotor -ge 1 -and $leftRotor -le 5 -and 
            $middleRotor -ge 1 -and $middleRotor -le 5 -and 
            $rightRotor -ge 1 -and $rightRotor -le 5) {
            
            # Install rotors in array (index 0=rightmost, 2=leftmost)
            $this.Rotors[0] = $this.AvailableRotors[$rightRotor - 1]   # Right rotor
            $this.Rotors[1] = $this.AvailableRotors[$middleRotor - 1] # Middle rotor  
            $this.Rotors[2] = $this.AvailableRotors[$leftRotor - 1]   # Left rotor
            
            # Reset all positions and ring settings when changing rotor configuration
            foreach ($rotor in $this.Rotors) {
                $rotor.Position = 0
                $rotor.RingSetting = 0
            }
        }
    }
    
    # Encode a single character through the complete Enigma process
    # This simulates pressing a key and observing the lit-up result letter
    # The complete path: Plugboard -> Rotors -> Reflector -> Rotors -> Plugboard
    [char] EncodeCharacter([char]$letter) {
        # Convert to uppercase for processing
        [char]$letter = [char]::ToUpper($letter)
        
        # Only process alphabetic characters; others pass through unchanged
        if ($letter -lt 'A' -or $letter -gt 'Z') {
            return $letter
        }
        
        # CRITICAL: Rotor advancement happens BEFORE encryption
        # This is the historical behavior that affects the timing of rotor movements
        $this.AdvanceRotors()
        
        # Step 1: Through the plugboard (first pass)
        [char]$encoded = $this.Plugboard.Encode($letter)
        
        # Step 2: Through all rotors in forward direction (right to left)
        for ([int]$i = 0; $i -lt $this.Rotors.Length; $i++) {
            $encoded = $this.Rotors[$i].EncodeForward($encoded)
        }
        
        # Step 3: Through the reflector (signal reversal point)
        $encoded = $this.Reflector.Reflect($encoded)
        
        # Step 4: Back through all rotors in reverse direction (left to right)
        for ([int]$i = $this.Rotors.Length - 1; $i -ge 0; $i--) {
            $encoded = $this.Rotors[$i].EncodeBackward($encoded)
        }
        
        # Step 5: Through the plugboard again (second pass)
        $encoded = $this.Plugboard.Encode($encoded)
        
        return $encoded
    }
    
    # Implement the famous Enigma rotor advancement mechanism
    # This includes the "double-stepping" anomaly that was crucial to breaking Enigma
    [void] AdvanceRotors() {
        # Double-stepping: If middle rotor is at its notch, both middle and left rotors advance
        # This happens because the middle rotor's notch engages the left rotor's mechanism
        # while also being advanced by the right rotor - a mechanical quirk
        if ($this.Rotors[1].AtNotch()) {
            # Middle rotor at notch - double stepping occurs
            $this.Rotors[1].Advance()  # Middle rotor advances itself
            $this.Rotors[2].Advance()  # Left rotor also advances
        }
        # Normal stepping: If right rotor is at its notch, middle rotor advances
        elseif ($this.Rotors[0].AtNotch()) {
            # Right rotor at notch - middle rotor advances normally
            $this.Rotors[1].Advance()
        }
        
        # The rightmost rotor ALWAYS advances with each keystroke
        # This provides the primary source of variation in Enigma encryption
        $this.Rotors[0].Advance()
    }
    
    # Encode a complete message through the Enigma machine
    # Each character is processed individually, allowing rotor advancement between letters
    [string] EncodeMessage([string]$message) {
        [string]$result = ""
        # Process each character individually to allow proper rotor advancement
        foreach ($char in $message.ToCharArray()) {
            $result += $this.EncodeCharacter($char)
        }
        return $result
    }
}

# Main PowerShell function for Enigma encryption/decryption
# This provides a convenient interface for using the Enigma machine simulator
# Since Enigma is reciprocal, the same settings that encrypt also decrypt
function Invoke-EnigmaEncryption {
    param(
        # The text to encrypt or decrypt (spaces will be removed)
        [Parameter(Mandatory=$true)]
        [string]$Text,
        
        # Which rotors to use: left, middle, right (1-5 for rotors I-V)
        # Default: III-II-I (historically common configuration)
        [Parameter(Mandatory=$false)]
        [int[]]$RotorConfiguration = @(3, 2, 1),
        
        # Visible rotor positions (Grundstellung) - what operator sees in windows
        # Each letter corresponds to the visible rotor position (A-Z)
        [Parameter(Mandatory=$false)]
        [string]$RotorPositions = "AAA",
        
        # Ring settings (Ringstellung) - internal rotor offset settings
        # These affect the relationship between visible position and internal wiring
        [Parameter(Mandatory=$false)]
        [string]$RingSettings = "AAA",
        
        # Plugboard connections - pairs of letters to swap
        # Format: "AB CD EF" means A<->B, C<->D, E<->F
        # Maximum 10 pairs (20 letters) can be connected
        [Parameter(Mandatory=$false)]
        [string]$PlugboardConnections = ""
    )
    
    # Create and configure the Enigma machine
    [EnigmaMachine]$enigma = [EnigmaMachine]::new()
    
    # Configure rotor selection (if valid configuration provided)
    if ($RotorConfiguration.Length -eq 3) {
        $enigma.SetRotorConfiguration($RotorConfiguration[0], $RotorConfiguration[1], $RotorConfiguration[2])
    }
    
    # IMPORTANT: Ring settings must be applied BEFORE rotor positions
    # This is because ring settings affect the internal rotor mechanics
    $enigma.SetRingSettings($RingSettings.ToUpper())
    
    # Set the visible rotor positions (what the operator sees)
    $enigma.SetRotorPositions($RotorPositions.ToUpper())
    
    # Configure plugboard connections if provided
    if ($PlugboardConnections) {
        # Split the connection string into individual pairs
        [string[]]$connections = $PlugboardConnections -split '\s+'
        foreach ($connection in $connections) {
            # Each connection should be exactly 2 characters (a letter pair)
            if ($connection.Length -eq 2) {
                $enigma.AddPlugboardConnection([char]$connection[0], [char]$connection[1])
            }
        }
    }
    
    # Process the input text through the Enigma machine
    # Remove spaces and convert to uppercase (standard Enigma practice)
    [string]$cleanText = $Text.ToUpper() -replace '\s', ''
    [string]$result = $enigma.EncodeMessage($cleanText)
    
    # Format output in historically accurate 5-letter groups
    # This matches the standard German radio transmission format
    # 10 groups per line was common practice to prevent transmission errors
    [string]$formattedResult = ""
    [int]$groupCount = 0
    for ([int]$i = 0; $i -lt $result.Length; $i += 5) {
        # Add line breaks every 10 groups, spaces between groups
        if ($i -gt 0) { 
            if ($groupCount -eq 10) {
                $formattedResult += "`n"  # New line after 10 groups
                $groupCount = 0
            } else {
                $formattedResult += " "   # Space between groups
            }
        }
        # Extract 5-character group (or remaining characters if less than 5)
        $formattedResult += $result.Substring($i, [Math]::Min(5, $result.Length - $i))
        $groupCount++
    }
    
    return $formattedResult
}

# ==================================================================================
# EXAMPLE CONFIGURATIONS AND TEST CASES
# ==================================================================================

# Reference: Online Enigma simulator for verification
# https://cryptii.com/pipes/enigma-machine

# Standard configuration with minimal security (10 plugboard pairs)
# This represents a typical daily key setting that might have been used
[hashtable]$Standard = @{
    RotorConfiguration = @(1, 2, 3)  # Rotors I-II-III (common early war setup)
    RotorPositions = "AAA"           # All rotors start at position A
    RingSettings = "AAA"             # No ring offset applied
    PlugboardConnections = "AB CD EF GH IJ KL MN OP QR ST"  # 10 pairs for extra security
}

# Kriegsmarine (German Navy) complex configuration from 1943
# U-boats used more sophisticated settings for critical communications
[hashtable]$Marine1943 = @{
    RotorConfiguration = @(5, 4, 3)    # Rotors V-IV-III (late war, more secure)
    RotorPositions = "BLA"             # Typical U-boat call sign format
    RingSettings = "AJD"               # Complex ring settings to confuse cryptanalysts
    PlugboardConnections = "AB CD EF GH IJ KL MN OP QR ST"  # Maximum plugboard complexity
}

# Test configuration for development and debugging
[hashtable]$test = @{
    RotorConfiguration = @(1, 2, 3)   # Simple rotor setup
    RotorPositions = "ABC"            # Different starting positions for testing
    RingSettings = "XYZ"              # Complex ring settings to test offset calculations
    PlugboardConnections = "AB CD"    # Minimal plugboard for easier debugging
}

# ==================================================================================
# DEMONSTRATION AND VERIFICATION
# ==================================================================================

# Demonstrate the reciprocal nature of Enigma encryption
# The same configuration that encrypts a message will also decrypt it
Write-Host
Write-Host "=== Enigma Machine Demonstration ===" -ForegroundColor Cyan

# Encrypt a test message using the standard configuration
[string]$encrypted = Invoke-EnigmaEncryption -Text @"
ENIGMA CHALLENGE
"@ @Standard

# Decrypt the encrypted message using the same configuration
[string]$decrypted = Invoke-EnigmaEncryption -Text $encrypted @Standard

# Display results with expected values for verification
Write-Host "Original : ENIGMA CHALLENGE" -ForegroundColor Green
Write-Host "Encrypted: $encrypted" -ForegroundColor Yellow  # Expected: FYCLD YEKEA BAXXW
Write-Host "Decrypted: $decrypted" -ForegroundColor Green   # Expected: ENIGM ACHAL LENGE
Write-Host
Write-Host "Note: Spaces are removed during processing, which is historically accurate." -ForegroundColor Gray
