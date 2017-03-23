--
--
-- Nginx通过Lua脚本调用GraphicsMagick类库动态处理图片

-- 20151021135627_23184_t3_w_s150x100.jpg
--
-- User: huangjialin
-- Date: 16/01/15 16:40
--


-- 检测路径是否目录
function is_dir(s_path)
    if type(s_path) ~= "string" then
        return false
     end
    local response = os.execute("cd " .. s_path)
    if response == 0 then
        return true
    end
    return false
end

-- 文件是否存在
function file_exists(name)
    local f = io.open(name, "r")
    if f ~= nil then
         io.close(f)
         return true
    else
        return false
    end
end

-- 获取文件路径
function get_file_dir(filename)
    return string.match(filename, "(.+)/[^/]*%.%w+$")
end

-- gm 命令路径
local gm_path = '/usr/bin/gm'

-- 创建文件夹
if not is_dir(get_file_dir(ngx.var.img_thumb_path)) then
    os.execute("mkdir -p " .. get_file_dir(ngx.var.img_thumb_path))
end

if (file_exists(ngx.var.img_src_path)) then
    local cmd
	
	-- 压缩尺寸
	local size_str = ' ';
	if(tonumber(ngx.var.img_width) ~= nil and tonumber(ngx.var.img_height) ~= nil) then
		size_str = size_str .. ngx.var.img_width .. 'x' .. ngx.var.img_height;
		-- 指定裁剪模式
		if(ngx.var.img_resize_type == '1') then
			size_str = size_str .. '!'   --强制宽高
		elseif (ngx.var.img_resize_type == '2') then
			size_str = size_str .. '^'   --强制高	 
		elseif (ngx.var.img_resize_type == '3') then
			size_str = ' ^' .. size_str   --强制宽   
		else
			size_str = size_str .. ''	 --等比例
		end
		
		size_str = " -resize " .. size_str 
	end
	
	-- +profile "*"  去除 ICM, EXIF, IPTC 等信息
	local default_options = ' +profile "*" '
	
	if (ngx.var.img_src_format=="gif" or ngx.var.img_src_format=="GIF") and ngx.var.img_thumb_fotmat ~="gif" then
		cmd = gm_path .. ' convert ' .. '\''..ngx.var.img_src_path..'[0]'..'\''
		cmd = cmd ..size_str..default_options..ngx.var.img_thumb_path
	else
		cmd = gm_path .. ' convert ' .. ngx.var.img_src_path
		cmd = cmd ..size_str..default_options..ngx.var.img_thumb_path
	end
	
	ngx.log(ngx.INFO, cmd);
	os.execute(cmd);
	 
	-- 右下角加水印
	if (ngx.var.img_watermark=='w') then
		 cmd = gm_path .. ' composite -gravity southeast -dissolve 80 '..ngx.var.watermark
		 cmd = cmd .." "..ngx.var.img_thumb_path.." "..ngx.var.img_thumb_path
	end
	
	ngx.log(ngx.INFO, cmd);
	os.execute(cmd);
	
    ngx.exec(ngx.var.uri);
else
    ngx.exit(ngx.HTTP_NOT_FOUND);
end