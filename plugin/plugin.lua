local function is_html (format)
  return format == 'html' or format == 'html4' or format == 'html5'
end

local function is_latex (format)
  return format == 'latex'
end

local codeFont = os.getenv("CODE_FONT") or "DejaVue Sans Mono"
local textFont = os.getenv("TEXT_FONT") or "Source Sans Pro"

local texTextFont = "\\setmainfont[]{".. textFont .."}"
local texCodeFont = "\\setmainfont[]{".. codeFont .."}"
local texCodeFontAlloy = "\\setmonofont[]{".. codeFont .."}"

local function tla_codeblock2tex(code)
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
    return texCodeFont .. tex .. texTextFont
end

local function alloy_codeblock2tex(code)
    tex = pandoc.pipe("pygmentize", {"-l", "alloy", "-O", "style=alloy,linenos=false,noclasses", "-f", "latex"}, code)
    return texCodeFontAlloy .. tex
end

local function alloy_codeblock2html(code)
    return pandoc.pipe("pygmentize", {"-l", "alloy", "-O", "style=alloy,linenos=false,noclasses", "-f", "html"}, code)
end

local plantumlPath = os.getenv("PLANTUML") or "plantuml.jar"
local plantumlFont = os.getenv("PLANTUML_FONT") or "Helvetica"

local function plantuml(puml, filetype, plantumlPath)
    local final = pandoc.pipe("java", {"-jar", plantumlPath, "-t" .. filetype, "-pipe", "-charset", "UTF8", "-SDefaultFontName=" .. plantumlFont}, puml)
    return final
end

function CodeBlock(block)
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
   if block.classes[1] == "plantuml" then
     if is_html(FORMAT) then
        -- "svg"
        -- "image/svg+xml"
        local img = plantuml(block.text, "png", plantumlPath)
        local fname = pandoc.sha1(img) .. ".png"
        pandoc.mediabag.insert(fname, "image/png", img)
        return pandoc.Para{ pandoc.Image({pandoc.Str("PlantUML Diagramm")}, fname) }
     end
     if is_latex(FORMAT) then
        local img = plantuml(block.text, "pdf", plantumlPath)
        local fname = pandoc.sha1(img) .. ".pdf"
        pandoc.mediabag.insert(fname, "application/pdf", img)
        return pandoc.Para{ pandoc.Image({pandoc.Str("PlantUML Diagramm")}, fname) }
     end
   end
   if block.classes[1] == "tla" then
     if is_html(FORMAT) then
       return block
     end
     if is_latex(FORMAT) then
        local tex = tla_codeblock2tex(block.text)
        return pandoc.RawBlock('latex',tex)
     end
   end
   return block
end
