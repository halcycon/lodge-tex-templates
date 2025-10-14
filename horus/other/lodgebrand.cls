\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{lodgebrand}[2025/09/15 v0.2 Lodge stationery class]

\DeclareOption*{\PassOptionsToClass{\CurrentOption}{article}}
\ProcessOptions\relax
\LoadClass[12pt]{article}

% Core packages
\RequirePackage{iftex}
\RequirePackage{geometry}
\RequirePackage{fancyhdr}
\RequirePackage{graphicx}
\RequirePackage{xcolor}
\RequirePackage{microtype}
\RequirePackage{ragged2e}
\RequirePackage{tikzpagenodes}
\RequirePackage{eso-pic}
\RequirePackage{enumitem}
\RequirePackage{tocloft}
\RequirePackage{kvoptions}
\RequirePackage{etoolbox}
\RequirePackage{xstring}
\RequirePackage{fontawesome5}
% Breakable highlighting support
\RequirePackage{soul}

% hyperref loaded later, after brand colors are defined
\ifPDFTeX
  \RequirePackage[T1]{fontenc}
  \RequirePackage[utf8]{inputenc}
  \RequirePackage{lmodern}
\else
  \RequirePackage{fontspec}
  % Default to a robust Palatino-like: TeX Gyre Pagella.
  % You can override via the `mainfont` branding key if desired.
  \setmainfont{TeX Gyre Pagella}
  \setsansfont{TeX Gyre Heros}
  \setmonofont{TeX Gyre Cursor}
  % Display font (optional, opt-in via key)
  \newcommand*\LB@DisplayFontSwitch{}
\fi

% ===== Brand variables =====
\newcommand*\LodgeName{Hundred Elms Lodge}
\newcommand*\LodgeNumber{No. 5749}
\newcommand*\LodgeStrapA{(Consecrated 10th October 1938)}
\newcommand*\LodgeStrapB{PATRON LODGE – MIDDLESEX 2020 FESTIVAL}
\newcommand*\LodgeAddress{58 Lilian Road\\London\\SW16 5HW}
\newcommand*\LodgeContacts{Adam Camp | Secretary | adam.camp@pglm.org.uk | 07792 554 609}
\newcommand*\LodgeFooterLeft{Registered Address: 58 Lilian Road, London SW16 5HW}
\newcommand*\LodgeFooterRight{Hundred Elms Lodge No. 5749}
\newcommand*\LodgeLogoPath{../assets/5749-Logo.pdf}

% Colors
\definecolor{brandcolor}{HTML}{0A2A5B} % deep navy blue
\definecolor{accentcolor}{HTML}{B5985A} % muted gold
\definecolor{textgray}{HTML}{0A2A5B}   % dark blue for body text
\definecolor{rubricred}{HTML}{B00020}  % rubric red
% Default gavel color (aligns with header/footer text color)
\newcommand*\LB@GavelColor{textgray}

% Load hyperlinks after colors are defined (uses brandcolor)
\RequirePackage[colorlinks=true,linkcolor=brandcolor,urlcolor=brandcolor,citecolor=brandcolor]{hyperref}

% Layout defaults (A4)
\newdimen\HeaderHeight \HeaderHeight=28mm
\newdimen\FooterHeight \FooterHeight=18mm
\newdimen\RuleThickness \RuleThickness=0.6pt
\newdimen\LB@LeftMargin \LB@LeftMargin=22mm
\newdimen\LB@RightMargin \LB@RightMargin=22mm
\newdimen\LB@BottomMargin \LB@BottomMargin=\dimexpr\FooterHeight+12mm\relax

% Use dimexpr so arithmetic doesn't leak tokens into output
\geometry{
  paper=a4paper,
  top=\dimexpr\HeaderHeight+10mm\relax,
  bottom=\LB@BottomMargin,
  left=\LB@LeftMargin,
  right=\LB@RightMargin
}
\setlength{\headheight}{16pt}
\setlength{\headsep}{10mm}
\setlength{\footskip}{\FooterHeight}

% ===== Branding setup macro =====
\SetupKeyvalOptions{family=lb, prefix=lb@}
\newcommand{\SetLodgeBranding}[1]{\setkeys{lb}{#1}}

% keys
\define@key{lb}{name}{\renewcommand*\LodgeName{#1}}
\define@key{lb}{number}{\renewcommand*\LodgeNumber{#1}}
\define@key{lb}{strapa}{\renewcommand*\LodgeStrapA{#1}}
\define@key{lb}{strapb}{\renewcommand*\LodgeStrapB{#1}}
\define@key{lb}{address}{\renewcommand*\LodgeAddress{#1}}
\define@key{lb}{contacts}{\renewcommand*\LodgeContacts{#1}}
\define@key{lb}{footer-left}{\renewcommand*\LodgeFooterLeft{#1}}
\define@key{lb}{footer-right}{\renewcommand*\LodgeFooterRight{#1}}
\define@key{lb}{logo}{\renewcommand*\LodgeLogoPath{#1}}
\define@key{lb}{brandcolor}{\colorlet{brandcolor}{#1}}
\define@key{lb}{accentcolor}{\colorlet{accentcolor}{#1}}
\define@key{lb}{rubric}{\colorlet{rubricred}{#1}}
\define@key{lb}{headerheight}{\HeaderHeight=#1}
\define@key{lb}{footerheight}{\FooterHeight=#1}
\define@key{lb}{rule}{\RuleThickness=#1}
\define@key{lb}{mainfont}{\ifPDFTeX\else\setmainfont{#1}\fi}
\define@key{lb}{sansfont}{\ifPDFTeX\else\setsansfont{#1}\fi}
\define@key{lb}{displayfont}{\ifPDFTeX\else\IfFontExistsTF{#1}{\newfontfamily\LBDisplay{#1}\renewcommand*\LB@DisplayFontSwitch{\LBDisplay}}{}\fi}
% Allow overriding the gavel icon color (e.g., gavelcolor=accentcolor)
\define@key{lb}{gavelcolor}{\renewcommand*\LB@GavelColor{#1}}
% Choose gavel icon implementation: fa (FontAwesome) or tikz
\newif\ifLBGavelFA \LBGavelFAfalse
\define@key{lb}{gavelicon}{\ifstrequal{#1}{fa}{\LBGavelFAtrue}{\LBGavelFAfalse}}

% ===== Header/Footer drawing =====
\newif\ifLBMinutesRule  \LBMinutesRulefalse
\newif\ifLBHeaderFill   \LBHeaderFilltrue
\newif\ifLBTopAccent    \LBTopAccentfalse
\newdimen\LB@RunTop
\LB@RunTop=22mm

% header text color dependent on fill
\newcommand*\LB@TextColor{white}
\newcommand*\EnableHeaderFill{\LBHeaderFilltrue\renewcommand*\LB@TextColor{white}}
\newcommand*\DisableHeaderFill{\LBHeaderFillfalse\renewcommand*\LB@TextColor{brandcolor}}

% computed sizes
\newdimen\LB@LogoSize

\newcommand*\LB@Header{
  \fancyhead{}\fancyfoot{}
  \AddToShipoutPictureFG*{
    \begin{tikzpicture}[remember picture, overlay]
      % Optional filled banner background
      \ifLBHeaderFill
        \fill[brandcolor] ([yshift=-2pt]current page.north west) rectangle ([yshift=-\HeaderHeight]current page.north east);
      \fi
      % Accent rule at bottom of header block (mirrors footer)
      \draw[line width=\RuleThickness,accentcolor] ([yshift=-\HeaderHeight]current page.north west) -- ([yshift=-\HeaderHeight]current page.north east);
      % Optional thin accent rule at the top margin for visual balance
      \ifLBTopAccent
        \draw[line width=0.4pt,accentcolor] ([yshift=-2pt]current page.north west) -- ([yshift=-2pt]current page.north east);
      \fi
      % compute logo size as 0.6*HeaderHeight
      \LB@LogoSize=.6\HeaderHeight
      \node[anchor=west] at ([xshift=18mm,yshift=-0.45\HeaderHeight]current page.north west) {\includegraphics[height=\LB@LogoSize]{\LodgeLogoPath}};
      \node[anchor=west, text=\LB@TextColor] at ([xshift=\dimexpr 18mm+\LB@LogoSize+6mm\relax,yshift=-0.5\HeaderHeight]current page.north west) {
        \begin{minipage}{0.7\paperwidth}
          {\LB@DisplayFontSwitch\addfontfeatures{LetterSpace=1}\bfseries\Large \LodgeName}~{\normalsize \LodgeNumber}\\[-1mm]
          {\footnotesize \LodgeStrapA}\\[-0.5mm]
          {\footnotesize \LodgeStrapB}
        \end{minipage}
      };
    \end{tikzpicture}
  }
}

\newcommand*\LB@Footer{
  \fancyfoot{}
  \fancyfoot[L]{\footnotesize\color{textgray}\RaggedRight \LodgeFooterLeft}
  \fancyfoot[R]{\footnotesize\color{textgray}\RaggedLeft \LodgeFooterRight}
  \fancyfoot[C]{\footnotesize\color{textgray} \LodgeContacts}
  \renewcommand{\footrulewidth}{\ifLBMinutesRule 0.4pt \else \RuleThickness \fi}
  \renewcommand{\footrule}{\hbox to\headwidth{\color{accentcolor}\leaders\hrule height \footrulewidth\hfill}}
}

\newcommand*\EnableLodgeBranding{\pagestyle{fancy}\renewcommand{\headrulewidth}{0pt}\LB@Header\LB@Footer}
\newcommand*\DisableLodgeFooter{\fancyfoot{}\renewcommand{\footrulewidth}{0pt}}
\newcommand*\UseMinutesFooterRule{\LBMinutesRuletrue}

% Match top spacing to footer spacing (top ~= bottom)
\newcommand*\UseTopSpacingLikeFooter{%
  \newgeometry{
    top=\dimexpr\FooterHeight+12mm\relax
  }
}

% Public toggles for top accent rule
\newcommand*\EnableTopAccentRule{\LBTopAccenttrue}
\newcommand*\DisableTopAccentRule{\LBTopAccentfalse}

% ===== Running header for pages after the first =====
% Configure the compact top margin used with the running header
\newcommand*\SetRunningTop[1]{\LB@RunTop=#1\relax}

% Header marks: use latest section title when available
\renewcommand{\sectionmark}[1]{\markright{#1}}
\renewcommand{\subsectionmark}[1]{\markright{#1}}

% A helper that behaves like `\section*` but also updates the running header mark and TOC
\newcommand*\Section[1]{\phantomsection\section*{#1}\markright{#1}\addcontentsline{toc}{section}{#1}}

% Unnumbered section that updates the running header but is NOT added to TOC
\newcommand*\SectionNoTOC[1]{\section*{#1}\markright{#1}}

% Enable a compact running header: gold rule + current section name
\newcommand*\EnableRunningHeader{%% call this from page 2 onward
  \newgeometry{top=\LB@RunTop,left=\LB@LeftMargin,right=\LB@RightMargin,bottom=\LB@BottomMargin}%% reduce only top margin; keep sides consistent
  \setlength{\headheight}{24.1pt}%% ensure enough space for header content (avoid fancyhdr warning)
  \fancyhead{}%% reset existing head
  \fancyhead[C]{\footnotesize\color{textgray}\nouppercase{\rightmark}}%% centre section title in same font/size as footer
  \renewcommand{\headrulewidth}{\ifLBMinutesRule 0.4pt \else \RuleThickness \fi}
  \renewcommand{\headrule}{\hbox to\headwidth{\color{accentcolor}\leaders\hrule height \headrulewidth\hfill}}%% gold rule under header
}

\setlength{\parskip}{6pt}
\setlength{\parindent}{0pt}
\setlist{nosep}

% ===== TOC (Agenda) styling + numbering helpers =====
% Compact vertical spacing and dot leaders to page numbers
\renewcommand{\cftsecfont}{\normalfont}
\renewcommand{\cftsecpagefont}{\normalfont}
\renewcommand{\cftsubsecfont}{\normalfont}
\renewcommand{\cftsubsecpagefont}{\normalfont}
\renewcommand{\cftsecleader}{\cftdotfill{\cftdotsep}}
\renewcommand{\cftsubsecleader}{\cftdotfill{\cftdotsep}}
\setlength{\cftbeforesecskip}{2pt}
\setlength{\cftbeforesubsecskip}{1pt}
\setlength{\cftsecindent}{0pt}
% Make sub-items indent slightly further than section text
\setlength{\cftsubsecindent}{2.6em}
% Reserve space for 2-digit section numbers (e.g., "12.")
\setlength{\cftsecnumwidth}{2.4em}
% Reserve space for sub-item letters (e.g., "a.")
\setlength{\cftsubsecnumwidth}{1.8em}

% Agenda numbering (independent of LaTeX section numbering)
\newcounter{agenda}
\newcounter{agendasub}
\newcommand*{\AgendaReset}{\setcounter{agenda}{0}\setcounter{agendasub}{0}}
\newcommand*{\AgendaNumber}{\theagenda.\space}

% Numbered agenda item: prints an unnumbered section, updates running header,
% and adds a numbered entry to the TOC.
\newcommand*{\AgendaItem}[1]{%
  \stepcounter{agenda}%
  \setcounter{agendasub}{0}% reset sub-item letters for each new agenda item
  \phantomsection
  \section*{\AgendaNumber#1}%
  \markright{#1}% running header shows clean title without number
  \addcontentsline{toc}{section}{\protect\numberline{\theagenda.}#1}% numbered TOC entry with trailing dot
}

% Agenda sub-item (e.g., under "Risings"): unnumbered subsection with TOC entry
\newcommand*{\AgendaSubItem}[1]{%
  \stepcounter{agendasub}%
  \phantomsection
  \subsection*{#1}% body shows no letter/number
  \addcontentsline{toc}{subsection}{\protect\numberline{(\alph{agendasub})}#1}% lettered TOC entry as (a)
}

% Agenda item that appears in TOC but does not increment number
\newcommand*{\AgendaItemNoNumber}[1]{%
  \phantomsection
  \section*{#1}%
  \markright{#1}%
  % Insert an empty number box so text aligns with numbered items
  \addcontentsline{toc}{section}{\protect\numberline{}#1}% unnumbered TOC entry aligned to text column
}

% ===== Ritual helpers (shared with lodgebook.cls) =====
\newcommand{\spoken}[1]{#1}
% Ensure rubric is always italic and non-bold regardless of surrounding style
\newcommand{\rubric}[1]{{\color{rubricred}\itshape\mdseries #1}}
% Role label styling (distinct font for clarity): small caps + slight tracking
% Works best under XeLaTeX; under pdfTeX we fall back to small caps bold.
\newcommand*{\RoleLabelStyle}{\sffamily\bfseries\scshape\ifdefined\addfontfeatures\addfontfeatures{LetterSpace=2}\fi}
\newcommand{\role}[1]{{\RoleLabelStyle #1}}

% Officer highlight configuration
\newif\ifLBOfficerHighlight \LBOfficerHighlightfalse
\newcommand*{\LB@OfficerCode}{}
% Default officer highlight color (rich green)
\definecolor{officerhl}{HTML}{1B5E20}
\newcommand*{\LB@OfficerColor}{officerhl}
\newcommand{\SetOfficerHighlightColor}[1]{\renewcommand*{\LB@OfficerColor}{#1}}
% Optional: underline highlighted spoken text for visibility (debug aid)
\newif\ifLBOfficerUnderline \LBOfficerUnderlinefalse
\newcommand*{\EnableOfficerUnderline}{\LBOfficerUnderlinetrue}
\newcommand*{\DisableOfficerUnderline}{\LBOfficerUnderlinefalse}
% Optional: background box for highlighted spoken text (strong visibility aid)
\newif\ifLBOfficerBox \LBOfficerBoxfalse
\newcommand*{\LB@OfficerBoxColor}{yellow}
\newcommand*{\EnableOfficerBox}{\LBOfficerBoxtrue}
\newcommand*{\DisableOfficerBox}{\LBOfficerBoxfalse}
\newcommand*{\SetOfficerBoxColor}[1]{\renewcommand*{\LB@OfficerBoxColor}{#1}}
% Style selector: colored-bold (text tinted + bold) vs box (background highlight, normal weight)
\newif\ifLBOfficerBold \LBOfficerBoldfalse
\newcommand*{\EnableOfficerColoredBold}{\LBOfficerBoldtrue\LBOfficerUnderlinefalse\LBOfficerBoxfalse}
\newcommand*{\EnableOfficerBoxStyle}{\LBOfficerBoldfalse\LBOfficerUnderlinefalse\LBOfficerBoxtrue}
% Generic style setter for convenience
\newcommand*{\SetOfficerHighlightStyle}[1]{%
  \StrDel{#1}{-}[\LB@stylekey]% remove hyphens for robust keys
  \csname LB@SetOfficerStyle@\LB@stylekey\endcsname}
\newcommand*{\LB@SetOfficerStyle@coloredbold}{\EnableOfficerColoredBold}
\newcommand*{\LB@SetOfficerStyle@box}{\EnableOfficerBoxStyle}
% Make soul tolerant of common inline macros appearing in spoken text
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
  \StrDel{#1}{ }[\LB@tmpCode]% remove spaces for robust matching
  \renewcommand*{\LB@OfficerCode}{\LB@tmpCode}%
  \LBOfficerHighlighttrue
}
\newcommand{\DisableOfficerHighlight}{\LBOfficerHighlightfalse}

% Line helper with optional officer highlighting
\newcommand{\linefrom}[2]{%
  \par\noindent
  \begingroup
    \def\LB@label{#1}%
    % Normalize label: remove spaces, then drop trailing colon
    \StrDel{\LB@label}{ }[\LB@labelTmp]
    \IfEndWith{\LB@labelTmp}{:}{\StrGobbleRight{\LB@labelTmp}{1}[\LB@labelBase]}{\edef\LB@labelBase{\LB@labelTmp}}%
    % Case-insensitive comparison
    \edef\LB@labelU{\expandafter\MakeUppercase\expandafter{\LB@labelBase}}%
    \edef\LB@codeU{\expandafter\MakeUppercase\expandafter{\LB@OfficerCode}}%
    \ifLBOfficerHighlight
      \IfStrEq{\LB@labelU}{\LB@codeU}{%
        \role{#1}\;{\begingroup
          \ifLBOfficerBox
            \sethlcolor{\LB@OfficerBoxColor}\hl{#2}% breakable background
          \else
            % Colored (tinted) text; optionally bold if requested
            \textcolor{\LB@OfficerColor}{\ifLBOfficerUnderline\ul{\ifLBOfficerBold\bfseries #2\else #2\fi}\else {\ifLBOfficerBold\bfseries #2\else #2\fi}\fi}%
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

% Common inline cues
\newcommand{\cue}[1]{\rubric{[#1]}}
% Inline aside (subtle note in gray italics)
\newcommand{\aside}[1]{{\color{textgray}\itshape #1}}

% Hammer-style gavel icon (TikZ), parameterized by scale and color
\newcommand{\LB@gavelicon}[2][1.0]{%% #1 scale, #2 color
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
\newcommand{\LB@GavelFA}[1][1.3]{\raisebox{-0.15ex}{\textcolor{\LB@GavelColor}{\scalebox{#1}{\faGavel}}}}
% Public macros route to the selected implementation; optional scale (e.g., \gavel or \gavel[1.8])
\NewDocumentCommand{\gavel}{o}{%% optional [scale]
  \IfNoValueTF{#1}{%% default size
    \ifLBGavelFA \LB@GavelFA[1.3] \else \LB@gavelicon[1.6]{\LB@GavelColor} \fi
  }{%% custom scale provided
    \ifLBGavelFA \LB@GavelFA[#1] \else \LB@gavelicon[#1]{\LB@GavelColor} \fi
  }%
}
\newcommand{\gavelx}[1]{\gavel\,\textcolor{\LB@GavelColor}{\,×\,#1}}

% Gavel pattern helpers
% spacing between quick strikes and pause
\newcommand{\gavelgap}{\,}
\newcommand{\gavelpause}{\,\,}
% single gavel
\newcommand{\gavelOne}{\gavel}
% three equidistant gavels (1st degree)
\newcommand{\gavelFirst}{\gavel\gavelgap\gavel\gavelgap\gavel}
% 1 then 2 quick (2nd degree)
\newcommand{\gavelSecond}{\gavel\gavelpause\gavel\gavelgap\gavel}
% 2 quick then 1 (3rd degree)
\newcommand{\gavelThird}{\gavel\gavelgap\gavel\gavelpause\gavel}
% two quick gavels: summons Tyler
\newcommand{\gavelSummons}{\gavel\gavelgap\gavel}

% Aliases using roman numerals
\newcommand{\gavelI}{\gavelFirst}
\newcommand{\gavelII}{\gavelSecond}
\newcommand{\gavelIII}{\gavelThird}

% Common cues
\newcommand{\stand}{\rubric{[STANDS]}}
\newcommand{\sit}{\rubric{[SITS]}}
\newcommand{\stepandsign}{\rubric{[STEP AND SIGN]}}