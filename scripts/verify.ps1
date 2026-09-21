<#
.SYNOPSIS
    Auditoria de Saúde, Linter de Frontmatter e Scanner de Segurança do Agent Toolkit.

.DESCRIPTION
    1. Audita a integridade e sintaxe das Skills (SKILL.md) e Subagentes (.md).
    2. Realiza varredura de segurança contra credenciais hardcoded.
    3. Audita o estado das junctions locais nos diretórios dos agentes.

.EXAMPLE
    .\scripts\verify.ps1
#>

[CmdletBinding()]
param()

$RepoRoot = (Resolve-Path "$PSScriptRoot\..").Path

Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "  🔍 Agent Toolkit — Auditoria de Saúde & Segurança     " -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "Repositório: $RepoRoot" -ForegroundColor Gray
Write-Host "--------------------------------------------------------" -ForegroundColor Gray

$errors = @()
$warnings = @()

# 1. AUDITAR SKILLS (SKILL.md)
Write-Host "`n1. Verificando integridade das Skills..." -ForegroundColor White
$skillFiles = Get-ChildItem -Path "$RepoRoot\skills" -Recurse -Filter "SKILL.md"

if ($skillFiles.Count -eq 0) {
    $errors += "Nenhuma skill encontrada em $RepoRoot\skills!"
} else {
    Write-Host "  Encontradas $($skillFiles.Count) skills." -ForegroundColor Gray
    foreach ($sf in $skillFiles) {
        $content = Get-Content -Path $sf.FullName -Raw
        if ($content -notmatch "^---[\r\n]+([\s\S]*?)[\r\n]+---") {
            $warnings += "Skill sem YAML frontmatter delimitado por '---': $($sf.FullName)"
        } else {
            $frontmatter = $matches[1]
            if ($frontmatter -notmatch "name\s*:" -and $frontmatter -notmatch "description\s*:") {
                $warnings += "Skill sem 'name:' ou 'description:' no frontmatter: $($sf.FullName)"
            }
        }
    }
}

# 2. AUDITAR SUBAGENTES (.md)
Write-Host "`n2. Verificando integridade dos Subagentes..." -ForegroundColor White
$agentFiles = Get-ChildItem -Path "$RepoRoot\agents" -Recurse -Filter "*.md"

if ($agentFiles.Count -eq 0) {
    $errors += "Nenhum subagente encontrado em $RepoRoot\agents!"
} else {
    Write-Host "  Encontrados $($agentFiles.Count) subagentes." -ForegroundColor Gray
    foreach ($af in $agentFiles) {
        $content = Get-Content -Path $af.FullName -Raw
        if ($content -notmatch "^---[\r\n]+([\s\S]*?)[\r\n]+---") {
            $warnings += "Subagente sem YAML frontmatter: $($af.FullName)"
        }
    }
}

# 3. SECURITY SCANNER (BUSCA DE CREDENCIAIS HARDCODED)
Write-Host "`n3. Executando Scanner de Segurança (Zero Secrets)..." -ForegroundColor White

$secretPatterns = @(
    "ghp_[A-Za-z0-9_]{30,}",
    "github_pat_[A-Za-z0-9_]{22,}",
    "sk-ant-[A-Za-z0-9_\-]{20,}",
    "sk-[A-Za-z0-9]{32,}",
    "-----BEGIN (RSA|OPENSSH|EC|PRIVATE) KEY-----"
)

$textFiles = Get-ChildItem -Path $RepoRoot -Recurse -File | Where-Object {
    $_.FullName -notmatch "\\\.git\\" -and
    $_.FullName -notmatch "\\\.claude\\" -and
    $_.FullName -notmatch "\\node_modules\\" -and
    $_.FullName -notmatch "\\dist\\" -and
    $_.FullName -notmatch "\.bak"
}

$secretsFound = 0
foreach ($tf in $textFiles) {
    $lines = Get-Content -Path $tf.FullName -ErrorAction SilentlyContinue
    $lineNum = 0
    foreach ($line in $lines) {
        $lineNum++
        foreach ($pat in $secretPatterns) {
            if ($line -match $pat) {
                # Ignora se for apenas documentação / regex
                if ($tf.FullName -notmatch "verify\.ps1" -and $tf.FullName -notmatch "design\.md" -and $tf.FullName -notmatch "plan\.md") {
                    $errors += "POSSÍVEL SEGREDO EXPOSTO em $($tf.FullName) [linha $lineNum] (padrão: $pat)"
                    $secretsFound++
                }
            }
        }
    }
}

if ($secretsFound -eq 0) {
    Write-Host "  [OK] Nenhum segredo exposto detectado no código/configs." -ForegroundColor Green
}

# 4. AUDITAR SAÚDE DAS JUNCTIONS LOCAIS (SE EXISTIREM)
Write-Host "`n4. Auditando integridade das Junctions nos Agentes..." -ForegroundColor White
$agentLocations = @(
    "$HOME\.claude\skills",
    "$HOME\.gemini\config\skills",
    "$HOME\.codex\skills"
)

foreach ($loc in $agentLocations) {
    if (Test-Path $loc) {
        $junctions = Get-ChildItem -Path $loc -Directory | Where-Object {
            $_.Attributes -band [System.IO.FileAttributes]::ReparsePoint
        }
        Write-Host "  $loc -> $($junctions.Count) junctions encontradas." -ForegroundColor Gray
        foreach ($j in $junctions) {
            if (-not (Test-Path $j.FullName)) {
                $warnings += "Dangling Junction (alvo inexistente): $($j.FullName)"
            }
        }
    }
}

# RELATÓRIO FINAL
Write-Host "`n========================================================" -ForegroundColor Cyan
if ($errors.Count -eq 0 -and $warnings.Count -eq 0) {
    Write-Host "  🎉 TODOS OS TESTES PASSARAM COM SUCESSO! (0 ERROS)   " -ForegroundColor Green
    Write-Host "========================================================" -ForegroundColor Cyan
    exit 0
} elseif ($errors.Count -eq 0) {
    Write-Host "  ⚠️ PASSOU COM $($warnings.Count) AVISOS (0 ERROS CRÍTICOS)  " -ForegroundColor Yellow
    Write-Host "========================================================" -ForegroundColor Cyan
    foreach ($w in $warnings) {
        Write-Host "  - AVISO: $w" -ForegroundColor Yellow
    }
    exit 0
} else {
    Write-Host "  ❌ FALHA NA AUDITORIA: $($errors.Count) ERROS ENCONTRADOS   " -ForegroundColor Red
    Write-Host "========================================================" -ForegroundColor Cyan
    foreach ($e in $errors) {
        Write-Host "  - ERRO: $e" -ForegroundColor Red
    }
    foreach ($w in $warnings) {
        Write-Host "  - AVISO: $w" -ForegroundColor Yellow
    }
    exit 1
}
