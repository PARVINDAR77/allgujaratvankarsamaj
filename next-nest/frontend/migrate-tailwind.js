const fs = require('fs');
const path = require('path');

const exactMatches = {
  'backgroundColor: "rgba(13, 27, 50, 0.85)"': 'bg-admin-bg-glass',
  'backgroundColor: "#0A1628"': 'bg-admin-bg',
  'backgroundColor: "#041026"': 'bg-admin-card',
  'backgroundColor: "#0D1B32"': 'bg-admin-card',
  'backgroundColor: "#0A162D"': 'bg-admin-navy',
  'backgroundColor: "rgba(220, 38, 38, 0.1)"': 'bg-red-500/10',
  'backgroundColor: "rgba(6, 78, 59, 0.6)"': 'bg-emerald-900/60',
  'backgroundColor: "rgba(136, 19, 55, 0.6)"': 'bg-rose-900/60',
  'backgroundColor: "rgba(212, 175, 55, 0.1)"': 'bg-admin-gold/10',
  'background: "linear-gradient(135deg, #D4AF37 0%, #F3E5AB 50%, #C59B27 100%)"': 'bg-gradient-to-br from-admin-gold via-admin-gold-light to-admin-gold-border',
  'background: "linear-gradient(135deg, rgba(212,175,55,0.3) 0%, rgba(243,229,171,0.1) 100%)"': 'bg-gradient-to-br from-admin-gold/30 to-admin-gold-light/10',
  'color: "#FFFFFF"': 'text-white',
  'color: "#D4AF37"': 'text-admin-gold',
  'color: "#8E9BAE"': 'text-admin-muted',
  'color: "#CBD5E1"': 'text-admin-muted-lighter',
  'color: "#FCA5A5"': 'text-red-300',
  'color: "#6EE7B7"': 'text-emerald-300',
  'color: "#FDA4AF"': 'text-rose-300',
  'color: "#F43F5E"': 'text-rose-500',
  'border: "1px solid rgba(212, 175, 55, 0.25)"': 'border border-admin-gold/25',
  'border: "1px solid rgba(212, 175, 55, 0.3)"': 'border border-admin-gold/30',
  'border: "1px solid rgba(212, 175, 55, 0.4)"': 'border border-admin-gold/40',
  'border: "1px solid rgba(212, 175, 55, 0.2)"': 'border border-admin-gold/20',
  'border: "1px solid rgba(212, 175, 55, 0.35)"': 'border border-admin-gold/35',
  'border: "1px solid #DC2626"': 'border border-red-600',
  'border: "1px solid rgba(16, 185, 129, 0.4)"': 'border border-emerald-500/40',
  'border: "1px solid rgba(244, 63, 94, 0.4)"': 'border border-rose-500/40',
  'borderBottom: "1px solid rgba(212, 175, 55, 0.1)"': 'border-b border-admin-gold/10',
  'borderBottom: "1px solid rgba(212, 175, 55, 0.3)"': 'border-b border-admin-gold/30',
  'border: "none"': 'border-none',
  'display: "flex"': 'flex',
  'flexDirection: "column"': 'flex-col',
  'justifyContent: "space-between"': 'justify-between',
  'justifyContent: "center"': 'justify-center',
  'justifyContent: "flex-end"': 'justify-end',
  'alignItems: "center"': 'items-center',
  'flexWrap: "wrap"': 'flex-wrap',
  'flexShrink: 0': 'shrink-0',
  'textAlign: "center"': 'text-center',
  'textAlign: "left"': 'text-left',
  'textAlign: "right"': 'text-right',
  'fontWeight: "bold"': 'font-bold',
  'fontWeight: 800': 'font-extrabold',
  'fontWeight: 700': 'font-bold',
  'fontWeight: 600': 'font-semibold',
  'fontWeight: 500': 'font-medium',
  'textTransform: "uppercase"': 'uppercase',
  'cursor: "pointer"': 'cursor-pointer',
  'overflow: "hidden"': 'overflow-hidden',
  'whiteSpace: "nowrap"': 'whitespace-nowrap',
  'textOverflow: "ellipsis"': 'text-ellipsis',
  'position: "relative"': 'relative',
  'position: "absolute"': 'absolute',
  'position: "fixed"': 'fixed',
  'borderCollapse: "collapse"': 'border-collapse',
  'outline: "none"': 'outline-none',
  'fontSize: "10px"': 'text-[10px]',
  'fontSize: "11px"': 'text-[11px]',
  'fontSize: "12px"': 'text-xs',
  'fontSize: "13px"': 'text-[13px]',
  'fontSize: "14px"': 'text-sm',
  'fontSize: "16px"': 'text-base',
  'fontSize: "24px"': 'text-2xl',
  'fontSize: "28px"': 'text-[28px]',
  'padding: "14px 18px"': 'py-[14px] px-[18px]',
  'padding: "18px 24px"': 'py-[18px] px-6',
  'padding: "24px"': 'p-6',
  'padding: "16px"': 'p-4',
  'padding: "10px 22px"': 'py-2.5 px-[22px]',
  'padding: "10px 14px 10px 38px"': 'py-2.5 pr-3.5 pl-[38px]',
  'padding: "10px 16px"': 'py-2.5 px-4',
  'padding: "6px 14px"': 'py-1.5 px-3.5',
  'padding: "48px 0"': 'py-12 px-0',
  'gap: "10px"': 'gap-[10px]',
  'gap: "14px"': 'gap-[14px]',
  'gap: "16px"': 'gap-4',
  'gap: "24px"': 'gap-6',
  'gap: "28px"': 'gap-7',
  'gap: "8px"': 'gap-2',
  'borderRadius: "16px"': 'rounded-2xl',
  'borderRadius: "12px"': 'rounded-xl',
  'borderRadius: "8px"': 'rounded-lg',
  'borderRadius: "50%"': 'rounded-full',
  'boxShadow: "0 10px 30px rgba(0, 0, 0, 0.4)"': 'shadow-[0_10px_30px_rgba(0,0,0,0.4)]',
  'boxShadow: "0 4px 14px rgba(212, 175, 55, 0.3)"': 'shadow-[0_4px_14px_rgba(212,175,55,0.3)]',
  'backdropFilter: "blur(16px)"': 'backdrop-blur-md',
  'width: "100%"': 'w-full',
  'width: "32px"': 'w-8',
  'height: "32px"': 'h-8',
  'height: "300px"': 'h-[300px]',
  'minWidth: "260px"': 'min-w-[260px]',
  'maxWidth: "160px"': 'max-w-[160px]',
  'left: "12px"': 'left-3',
  'top: "11px"': 'top-[11px]',
  'top: 0': 'top-0',
  'left: 0': 'left-0',
  'right: 0': 'right-0',
  'bottom: 0': 'bottom-0',
  'letterSpacing: "0.8px"': 'tracking-[0.8px]',
  'letterSpacing: "1px"': 'tracking-[1px]',
  'fontFamily: "monospace"': 'font-mono'
};

function processFile(filePath) {
  let content = fs.readFileSync(filePath, 'utf8');
  let original = content;

  // We find tags with style={{ ... }} including newlines
  const styleRegex = /<([a-zA-Z0-9_\.]+)([^>]*)style=\{\{([\s\S]+?)\}\}([^>]*)>/g;
  
  content = content.replace(styleRegex, (match, tag, before, styleStr, after) => {
    let newStyleStr = styleStr;
    const extractedClasses = [];

    // Order matters to replace exact substrings first
    for (const [cssProp, twClass] of Object.entries(exactMatches)) {
      if (newStyleStr.includes(cssProp)) {
        extractedClasses.push(twClass);
        newStyleStr = newStyleStr.replace(cssProp, '');
      }
    }

    // Cleanup newStyleStr (remove extra commas, spaces)
    newStyleStr = newStyleStr.split(',').map(s => s.trim()).filter(s => s.length > 0).join(', ');

    if (extractedClasses.length > 0) {
      const clsString = extractedClasses.join(' ');
      let hasExistingClass = false;

      // Extract existing className if any
      let existingClass = '';
      before = before.replace(/className=["']([^"']*)["']/, (m, existing) => {
        hasExistingClass = true;
        existingClass = existing;
        return '';
      });
      after = after.replace(/className=["']([^"']*)["']/, (m, existing) => {
        if (!hasExistingClass) existingClass = existing;
        hasExistingClass = true;
        return '';
      });

      const finalClasses = existingClass ? `${existingClass} ${clsString}` : clsString;
      
      let inner = ` className="${finalClasses}"`;

      if (newStyleStr.length === 0) {
        return `<${tag}${before}${inner}${after}>`;
      } else {
        return `<${tag}${before} style={{ ${newStyleStr} }}${inner}${after}>`;
      }
    }

    return match;
  });

  if (content !== original) {
    fs.writeFileSync(filePath, content, 'utf8');
    console.log(`Updated ${filePath}`);
  }
}

function traverseDir(dir) {
  const files = fs.readdirSync(dir);
  for (const file of files) {
    const fullPath = path.join(dir, file);
    if (fs.statSync(fullPath).isDirectory()) {
      traverseDir(fullPath);
    } else if (fullPath.endsWith('.tsx') || fullPath.endsWith('.ts')) {
      processFile(fullPath);
    }
  }
}

traverseDir(path.join(__dirname, 'src', 'app', 'admin'));
traverseDir(path.join(__dirname, 'src', 'components', 'admin'));
