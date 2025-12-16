#!/bin/bash
set -e  # Exit on any error

echo "=== Building Custom TinyTeX Distribution ==="

# Clean up any existing TinyTeX installation
rm -rf ~/.TinyTeX ~/bin/tlmgr ~/bin/*latex* ~/bin/tex* 2>/dev/null || true

# Install TinyTeX base
echo "Step 1: Installing TinyTeX base..."
wget -qO- "https://yihui.org/tinytex/install-bin-unix.sh" | sh

# Add TinyTeX to PATH for this session
export PATH="$HOME/bin:$PATH"

# Verify installation
echo "Step 2: Verifying base installation..."
which pdflatex || { echo "pdflatex not found!"; exit 1; }

# Initialize formats
echo "Step 3: Initializing formats..."
fmtutil-sys --all

# Set CTAN repository (use a reliable mirror)
echo "Step 4: Configuring CTAN repository..."
tlmgr option repository ctan

# Install your required packages
echo "Step 5: Installing LaTeX packages..."
tlmgr install \
    xstring needspace environ fp xint \
    readarray forloop listofitems nth \
    tcolorbox pgfplots siunitx tikzfill \
    pdfcol listings listingsutf8 \
    bera textcase soul textgreek fontawesome5 \
    palatino psnfss cbfonts mathpazo qrcode \
    mathtools ncctools hyphenat multicol \
    fancyhdr multirow accsupp

echo "Step 6: Updating filename database..."
mktexlsr

# Test the installation
echo "Step 7: Testing LaTeX compilation..."
cd /tmp
cat > test.tex << 'EOF'
\documentclass{article}
\usepackage{xstring}
\usepackage{tcolorbox}
\usepackage{fontawesome5}
\usepackage{qrcode}
\begin{document}
Hello from Custom TinyTeX! \faGithub
\end{document}
EOF

pdflatex -interaction=nonstopmode test.tex
if [ -f test.pdf ]; then
    echo "✓ Test compilation successful!"
    rm -f test.*
else
    echo "✗ Test compilation failed!"
    exit 1
fi

# Create tarball
echo "Step 8: Creating tarball..."
cd ~
tar czf custom-tinytex.tar.gz .TinyTeX bin

# Get size info
SIZE=$(du -h custom-tinytex.tar.gz | cut -f1)
echo "=== Build Complete ==="
echo "Archive created: ~/custom-tinytex.tar.gz"
echo "Size: $SIZE"
echo ""
echo "Next steps:"
echo "1. Upload this file to a hosting service (GitHub Releases, S3, etc.)"
echo "2. Update your Dockerfile to use this distribution"
