\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{lodgebook}[2025/09/16 v0.7 Lodge ritual book]
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{memoir}}
\ProcessOptions\relax
\LoadClass[12pt,twoside,openany]{memoir}

% ===== Core packages =====
\RequirePackage{iftex}
\RequirePackage{graphicx}
\RequirePackage{xcolor}
\RequirePackage{microtype}
\RequirePackage{ragged2e}
\RequirePackage{tikzpagenodes}
\RequirePackage{eso-pic}
\RequirePackage{kvoptions}
\RequirePackage{enumitem}
\RequirePackage{hyperref}
\RequirePackage{etoolbox}  % \ifblank
\RequirePackage{xstring}
% Breakable highlighting
\RequirePackage{soul}
% Optional FA icon support (for gavel parity with lodgebrand)
\RequirePackage{fontawesome5}

% ===== Fonts =====
\ifPDFTeX
  \RequirePackage[T1]{fontenc}
  \RequirePackage[utf8]{inputenc}
  \RequirePackage{lmodern}
\else
  \RequirePackage{fontspec}
  \setmainfont{TeX Gyre Pagella}
  \setsansfont{TeX Gyre Heros}
  \setmonofont{TeX Gyre Cursor}
\fi

% ===== Branding (override via \SetLodgeBranding) =====
\newcommand*\LodgeName{Hundred Elms Lodge}
\newcommand*\LodgeNumber{No. 5749}
\newcommand*\LodgeStrapA{(Consecrated 10th October 1938)}
\newcommand*\LodgeStrapB{PATRON LODGE – MIDDLESEX 2020 FESTIVAL}
\newcommand*\LodgeLogoPath{../assets/5749-Logo.pdf}

\definecolor{brandcolor}{HTML}{0A2A5B}  % deep navy
\definecolor{accentcolor}{HTML}{B5985A}  % muted gold
\definecolor{rubricred}{HTML}{B00020}    % rubric red
\definecolor{textgray}{HTML}{0A2A5B}     % match docs footer/body blue
\colorlet{textcolor}{black}

% ===== Memoir-native layout (no geometry) =====
\setstocksize{297mm}{210mm}         % A4
\settrimmedsize{297mm}{210mm}{*}    % A4
% Margins: inner/outer and upper/lower blocks
\setlrmarginsandblock{22mm}{22mm}{*}   % left/right
% Slightly reduce lower margin so footer sits closer to page bottom (like docs)
\setulmarginsandblock{22mm}{20mm}{*}   % upper/lower
\setheadfoot{14pt}{20pt}               % header height, footer height
\setheaderspaces{8mm}{*}{*}            % space between header and text
\checkandfixthelayout                   % <— important: applies layout

\setlength{\parskip}{6pt}
\setlength{\parindent}{0pt}
\setlist{itemsep=2pt, topsep=2pt}

\setsecnumdepth{subsection}
\maxsecnumdepth{subsection}
\settocdepth{subsection}

% ===== Page style: header + footer (normal pages) =====
\makepagestyle{lodgebook}
\makeheadrule{lodgebook}{\textwidth}{0.4pt}
\makefootrule{lodgebook}{\textwidth}{0.4pt}{3pt}

% Prefer section in header, fall back to chapter
\newcommand*\LB@headmark{\ifblank{\rightmark}{\leftmark}{\rightmark}}

\makeoddhead {lodgebook}{}{\small\sffamily\color{brandcolor}\LB@headmark}{}
\makeevenhead{lodgebook}{}{\small\sffamily\color{brandcolor}\LB@headmark}{}

% Footer: centre book title; page no left (odd) / right (even)
% Footer: match docs style — roman font, brand-colored text
\makeoddfoot {lodgebook}{\footnotesize\color{textgray}\thepage}%
                         {\footnotesize\color{textgray}\LodgeName\ \LodgeNumber}{}
\makeevenfoot{lodgebook}{}%
                         {\footnotesize\color{textgray}\LodgeName\ \LodgeNumber}%
                         {\footnotesize\color{textgray}\thepage}

% Header marks (what goes into \leftmark and \rightmark)
\makepsmarks{lodgebook}{
  \nouppercaseheads
  \createmark{chapter}{left}{shownumber}{}{ }
  \createmark{section}{right}{shownumber}{}{ }
}

% Use our style on normal pages
\pagestyle{lodgebook}

% ===== Key–value interface =====
\SetupKeyvalOptions{family=lbk, prefix=lbk@}
\newcommand{\SetLodgeBranding}[1]{\setkeys{lbk}{#1}}
\define@key{lbk}{name}{\renewcommand*\LodgeName{#1}}
\define@key{lbk}{number}{\renewcommand*\LodgeNumber{#1}}
\define@key{lbk}{strapa}{\renewcommand*\LodgeStrapA{#1}}
\define@key{lbk}{strapb}{\renewcommand*\LodgeStrapB{#1}}
\define@key{lbk}{logo}{\renewcommand*\LodgeLogoPath{#1}}
\define@key{lbk}{brandcolor}{\colorlet{brandcolor}{#1}}
\define@key{lbk}{accentcolor}{\colorlet{accentcolor}{#1}}
\define@key{lbk}{rubric}{\colorlet{rubricred}{#1}}
% Optional override for gavel color (defaults to header/footer blue)
\newcommand*\LBK@GavelColor{brandcolor}
\define@key{lbk}{gavelcolor}{\renewcommand*\LBK@GavelColor{#1}}
% Choose gavel icon implementation: fa (FontAwesome) or tikz
\newif\ifLBKGavelFA \LBKGavelFAtrue
\define@key{lbk}{gavelicon}{\ifstrequal{#1}{fa}{\LBKGavelFAtrue}{\LBKGavelFAfalse}}

% ===== Ritual helpers (aligned with lodgebrand.cls) =====
\newcommand{\spoken}[1]{#1}
% Ensure rubric is always italic and non-bold regardless of surrounding style
\newcommand{\rubric}[1]{{\color{rubricred}\itshape\mdseries #1}}
% Role label styling (distinct font for clarity): small caps + slight tracking
\newcommand*{\RoleLabelStyle}{\sffamily\bfseries\scshape\ifdefined\addfontfeatures\addfontfeatures{LetterSpace=2}\fi}
\newcommand{\role}[1]{{\RoleLabelStyle #1}}

% Officer highlight configuration
\newif\ifLBKOfficerHighlight \LBKOfficerHighlightfalse
\newcommand*{\LBK@OfficerCode}{}
% Default officer highlight color (rich green)
\definecolor{officerhl}{HTML}{1B5E20}
\newcommand*{\LBK@OfficerColor}{officerhl}
\newcommand{\SetOfficerHighlightColor}[1]{\renewcommand*{\LBK@OfficerColor}{#1}}
% Optional underline and box styles
\newif\ifLBKOfficerUnderline \LBKOfficerUnderlinefalse
\newcommand*{\EnableOfficerUnderline}{\LBKOfficerUnderlinetrue}
\newcommand*{\DisableOfficerUnderline}{\LBKOfficerUnderlinefalse}
\newif\ifLBKOfficerBox \LBKOfficerBoxfalse
\newcommand*{\LBK@OfficerBoxColor}{yellow}
\newcommand*{\EnableOfficerBox}{\LBKOfficerBoxtrue}
\newcommand*{\DisableOfficerBox}{\LBKOfficerBoxfalse}
\newcommand*{\SetOfficerBoxColor}[1]{\renewcommand*{\LBK@OfficerBoxColor}{#1}}
% Style selector: colored-bold vs box
\newif\ifLBKOfficerBold \LBKOfficerBoldfalse
\newcommand*{\EnableOfficerColoredBold}{\LBKOfficerBoldtrue\LBKOfficerUnderlinefalse\LBKOfficerBoxfalse}
\newcommand*{\EnableOfficerBoxStyle}{\LBKOfficerBoldfalse\LBKOfficerUnderlinefalse\LBKOfficerBoxtrue}
\newcommand*{\SetOfficerHighlightStyle}[1]{\StrDel{#1}{-}[\LBK@stylekey]\csname LBK@SetOfficerStyle@\LBK@stylekey\endcsname}
\newcommand*{\LBK@SetOfficerStyle@coloredbold}{\EnableOfficerColoredBold}
\newcommand*{\LBK@SetOfficerStyle@box}{\EnableOfficerBoxStyle}
% Soul registrations for inline macros that may appear in spoken text
\soulregister\cue7
\soulregister\gavel7
\soulregister\gavelOne7
\soulregister\gavelFirst7
\soulregister\gavelSecond7
\soulregister\gavelThird7
\soulregister\gavelSummons7
\soulregister\stand7
\soulregister\sit7
\soulregister\stepandsign7
% Enable/disable highlighting for a specific officer code (e.g., WM)
\newcommand{\HighlightOfficer}[1]{%
  \StrDel{#1}{ }[\LBK@tmpCode]% remove spaces for robust matching
  \renewcommand*{\LBK@OfficerCode}{\LBK@tmpCode}%
  \LBKOfficerHighlighttrue
}
\newcommand{\DisableOfficerHighlight}{\LBKOfficerHighlightfalse}

% Line helper with optional officer highlighting (parity with lodgebrand.cls)
\newcommand{\linefrom}[2]{%
  \par\noindent
  \begingroup
    \def\LBK@label{#1}%
    % Normalize label: remove spaces, then drop trailing colon
    \StrDel{\LBK@label}{ }[\LBK@labelTmp]%
    \IfEndWith{\LBK@labelTmp}{:}{\StrGobbleRight{\LBK@labelTmp}{1}[\LBK@labelBase]}{\edef\LBK@labelBase{\LBK@labelTmp}}%
    % Case-insensitive comparison
    \edef\LBK@labelU{\expandafter\MakeUppercase\expandafter{\LBK@labelBase}}%
    \edef\LBK@codeU{\expandafter\MakeUppercase\expandafter{\LBK@OfficerCode}}%
    \ifLBKOfficerHighlight
      \IfStrEq{\LBK@labelU}{\LBK@codeU}{%
        \role{#1}\;{\begingroup
          \ifLBKOfficerBox
            \sethlcolor{\LBK@OfficerBoxColor}\hl{#2}% breakable background
          \else
  % Colored (tinted) text; optionally bold if requested
            \textcolor{\LBK@OfficerColor}{\ifLBKOfficerUnderline\ul{\ifLBKOfficerBold\bfseries #2\else #2\fi}\else {\ifLBKOfficerBold\bfseries #2\else #2\fi}\fi}%
          \fi
        \endgroup}%
      }{%
        \role{#1}\;\spoken{#2}% default rendering
      }%
    \else
      \role{#1}\;\spoken{#2}% default rendering
    \fi
  \endgroup
}
\newcommand{\rubline}[1]{\par\noindent\rubric{#1}}
% Common inline cues and asides
\newcommand{\cue}[1]{\rubric{[#1]}}
\newcommand{\aside}[1]{{\color{textgray}\itshape #1}}
\newcommand{\stand}{\rubric{[STANDS]}}
\newcommand{\sit}{\rubric{[SITS]}}
\newcommand{\stepandsign}{\rubric{[STEP AND SIGN]}}

% Gavel icon parity with lodgebrand.cls
% TikZ hammer-style gavel icon, parameterized by scale and color
\newcommand{\LBK@gavelicon}[2][1.0]{%% #1 scale, #2 color
  \begin{tikzpicture}[baseline=-0.2ex, x=1ex, y=1ex, scale=#1]
    % head: horizontal block
    \fill[#2, rounded corners=0.25ex] (0.35,-0.40) rectangle (1.15,-0.70);
    \draw[#2, line width=0.5pt, rounded corners=0.25ex] (0.35,-0.40) rectangle (1.15,-0.70);
    % collar
    \draw[#2, line width=0.6pt] (0.98,-0.70) -- (0.98,-0.40);
    % handle: thick diagonal
    \draw[#2, line width=1.0pt, line cap=round] (1.05,-0.55) -- (1.90,-1.30);
  \end{tikzpicture}%
}
% FontAwesome gavel (optional)
\newcommand{\LBK@GavelFA}[1][1.3]{\raisebox{-0.15ex}{\textcolor{\LBK@GavelColor}{\scalebox{#1}{\faGavel}}}}
% Public macros route to the selected implementation; optional scale
\NewDocumentCommand{\gavel}{o}{%% optional [scale]
  \IfNoValueTF{#1}{%% default size
    \ifLBKGavelFA \LBK@GavelFA[1.3] \else \LBK@gavelicon[1.6]{\LBK@GavelColor} \fi
  }{%% custom scale provided
    \ifLBKGavelFA \LBK@GavelFA[#1] \else \LBK@gavelicon[#1]{\LBK@GavelColor} \fi
  }%%
}
\newcommand{\gavelx}[1]{\gavel\,\textcolor{\LBK@GavelColor}{\,×\,#1}}
% Gavel sequences
\newcommand{\gavelgap}{\,}
\newcommand{\gavelpause}{\,\,}
\newcommand{\gavelOne}{\gavel}
\newcommand{\gavelFirst}{\gavel\gavelgap\gavel\gavelgap\gavel}
\newcommand{\gavelSecond}{\gavel\gavelpause\gavel\gavelgap\gavel}
\newcommand{\gavelThird}{\gavel\gavelgap\gavel\gavelpause\gavel}
\newcommand{\gavelSummons}{\gavel\gavelgap\gavel}
\newcommand{\gavelI}{\gavelFirst}
\newcommand{\gavelII}{\gavelSecond}
\newcommand{\gavelIII}{\gavelThird}

% ===== Optional pages toggles =====
\newif\ifIncludeCover \IncludeCovertrue
\newif\ifIncludeTitle \IncludeTitletrue
\newif\ifIncludeFront \IncludeFronttrue
\newcommand{\IncludeCoverPage}{\IncludeCovertrue}
\newcommand{\ExcludeCoverPage}{\IncludeCoverfalse}
\newcommand{\IncludeTitlePage}{\IncludeTitletrue}
\newcommand{\ExcludeTitlePage}{\IncludeTitlefalse}
\newcommand{\IncludeFrontMatter}{\IncludeFronttrue}
\newcommand{\ExcludeFrontMatter}{\IncludeFrontfalse}

% ===== Makers: cover / title / front matter =====
\newcommand{\MakeCoverPage}{%
  \ifIncludeCover
    \clearpage\thispagestyle{empty}
    \AddToShipoutPictureFG*{%
      \begin{tikzpicture}[remember picture,overlay]
        \draw[accentcolor,line width=0.8pt]
          ([yshift=-18mm]current page.north west) -- ([yshift=-18mm]current page.north east);
        \draw[accentcolor,line width=0.8pt]
          ([yshift=18mm] current page.south west) -- ([yshift=18mm] current page.south east);
      \end{tikzpicture}}
    \vspace*{28mm}
    \begin{center}
      \includegraphics[height=28mm]{\LodgeLogoPath}\\[8mm]
      {\sffamily\bfseries\Huge \LodgeName}\\[2mm]
      {\sffamily\Large \LodgeNumber}\\[3mm]
      {\large\color{brandcolor} Ritual \& Guidance}\\[16mm]
      {\normalsize\color{brandcolor} \LodgeStrapA}\\[-1mm]
      {\normalsize\color{brandcolor} \LodgeStrapB}
    \end{center}
    \clearpage
  \fi
}

\newcommand{\MakeTitlePage}[3]{%
  \ifIncludeTitle
    \thispagestyle{empty}
    \vspace*{24mm}
    \begin{center}
      {\Huge\bfseries #1}\\[3mm]
      {\large #2}\\[10mm]
      {\normalsize #3}
    \end{center}
    \clearpage
  \fi
}

\newcommand{\MakeFrontMatter}[1]{%
  \ifIncludeFront
    \frontmatter
    \pagestyle{plain}% TOC etc.: no head/foot
    #1
    \tableofcontents*
    \clearpage
    \mainmatter
    \pagestyle{lodgebook}% resume normal pages
  \fi
}

% ===== Chapter helper: chapter opening page has NO head/foot,
%      next and subsequent pages use full header+footer
% Usage: \ChapterPage{Long Title} or \ChapterPage[Short]{Long Title}
\newcommand{\ChapterPage}[2][]{%
  \clearpage
  \if\relax\detokenize{#1}\relax \chapter{#2}\else \chapter[#1]{#2}\fi
  \thispagestyle{plain}% chapter title page: no head/foot
  \clearpage
  \pagestyle{lodgebook}% make sure from here on we use header+footer
}

% ===== Hyperref =====
\hypersetup{
  colorlinks=true,
  linkcolor=brandcolor,
  urlcolor=brandcolor,
  citecolor=brandcolor,
  pdfauthor={\LodgeName\, \LodgeNumber},
  pdftitle={Ritual & Guidance}
}
