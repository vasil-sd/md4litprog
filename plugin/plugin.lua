local function is_html (format)
  return format == 'html' or format == 'html4' or format == 'html5'
end

local function is_latex (format)
  return format == 'latex'
end

local codeFont = os.getenv("CODE_FONT") or "DejaVu Sans Mono"
local textFont = os.getenv("TEXT_FONT") or "Source Sans Pro"
local alloyCSS = os.getenv("ALLOY_CSS") or ""
local linum = os.getenv("LINE_NUMBERS") or "0"

local texTextFont = "\\setmainfont[]{".. textFont .."}\n"
local texCodeFont = "\\setmainfont[]{".. codeFont .."}\n"
local texCodeFontAlloy = "\\setmonofont[]{".. codeFont .."}\n"

local function tlaplus_codeblock2tex(code)
    local tmp = os.tmpname()
    local tmpdir = string.match(tmp, "^(.*[\\/])") or "."
    local f = io.open(tmp .. ".tla", 'w')
    f:write(code)
    f:close()
    os.execute("java tla2tex.TLA -shade -noPcalShade -number -noProlog -noEpilog -ptSize 10 -metadir " .. tmpdir  .. " " .. tmp .. ".tla" .. " > /dev/null 2>&1")
    os.remove(tmp .. ".tla")
    os.remove(tmp .. ".dvi")
    os.remove(tmp .. ".log")
    os.remove(tmp .. ".aux")
    os.remove(tmp)
    tex=pandoc.pipe("awk",{"BEGIN{f=0} /end{document}/{f=0} f==1 {print} /begin{document}/{f=1}", tmp .. ".tex"},"")
    os.remove(tmp .. ".tex")
    return texCodeFont .. "\\begin{snugshade}\n" .. tex .. "\\end{snugshade}\n" .. texTextFont
end

local function alloy_codeblock2tex(code)
    local linenos = "false"
    if linum == "1" then
        linenos = "true"
    end
    tex = pandoc.pipe("pygmentize", {"-l", "alloy", "-O", "style=alloy,linenos=" .. linenos .. ",noclasses", "-f", "latex"}, code)
    return texCodeFontAlloy .. "\\begin{snugshade}\n" .. tex .. "\\end{snugshade}\n"
end

local function alloy_codeblock2html(code)
    local linenos = ""
    if linum == "1" then
        linenos = "linenos=inline,"
    end
    local options = ""
    if alloyCSS == "" then
        options = linenos .. "style=alloy,noclasses"
    else
        options = linenos .. "noclobber_cssfile=True,cssfile=" .. alloyCSS  .. ",noclasses"
    end
    return pandoc.pipe("pygmentize", {"-l", "alloy", "-O", options, "-f", "html"}, code)
end

local function tla_codeblock2tex(code)
    local linenos = "false"
    if linum == "1" then
        linenos = "true"
    end
    tex = pandoc.pipe("pygmentize", {"-l", "tla", "-O", "linenos=" .. linenos .. ",noclasses", "-f", "latex"}, code)
    return texCodeFontAlloy .. "\\begin{snugshade}\n" .. tex .. "\\end{snugshade}\n"
end

local function tla_codeblock2html(code)
    local linenos = ""
    if linum == "1" then
        linenos = "linenos=inline,"
    end
    local options = ""
    options = linenos .. "noclasses"
    return pandoc.pipe("pygmentize", {"-l", "tla", "-O", options, "-f", "html"}, code)
end

local function is_tla_module(code)
    if string.find(string.sub(code, 1, math.min(string.len(code), 80)),"MODULE ", 1, true) ~= nil then
      return true
    end
    return false
end

function CodeBlock(block)
   if block.classes[1] == "tla" then
     if is_html(FORMAT) then
        local html = tla_codeblock2html(block.text)
        return pandoc.RawBlock('html',html)
     end
     if is_latex(FORMAT) then
        if is_tla_module(block.text) then
           local tex = tlaplus_codeblock2tex(block.text)
           return pandoc.RawBlock('latex',tex)
        else
           local tex = tla_codeblock2tex(block.text)
           return pandoc.RawBlock('latex',tex)
        end
     end
   end
   if block.classes[1] == "alloy" then
     if is_html(FORMAT) then
        local html = alloy_codeblock2html(block.text)
        return pandoc.RawBlock('html',html)
     end
     if is_latex(FORMAT) then
        local tex = alloy_codeblock2tex(block.text)
        return pandoc.RawBlock('latex',tex)
     end
   end
   return block
end
