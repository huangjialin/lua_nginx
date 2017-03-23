--
--
-- Nginxͨ��Lua�ű�����GraphicsMagick��⶯̬����ͼƬ

-- 20151021135627_23184_t3_w_s150x100.jpg
--
-- User: huangjialin
-- Date: 16/01/15 16:40
--


-- ���·���Ƿ�Ŀ¼
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

-- �ļ��Ƿ����
function file_exists(name)
    local f = io.open(name, "r")
    if f ~= nil then
         io.close(f)
         return true
    else
        return false
    end
end

-- ��ȡ�ļ�·��
function get_file_dir(filename)
    return string.match(filename, "(.+)/[^/]*%.%w+$")
end

-- gm ����·��
local gm_path = '/usr/bin/gm'

-- �����ļ���
if not is_dir(get_file_dir(ngx.var.img_thumb_path)) then
    os.execute("mkdir -p " .. get_file_dir(ngx.var.img_thumb_path))
end

if (file_exists(ngx.var.img_src_path)) then
    local cmd
	
	-- ѹ���ߴ�
	local size_str = ' ';
	if(tonumber(ngx.var.img_width) ~= nil and tonumber(ngx.var.img_height) ~= nil) then
		size_str = size_str .. ngx.var.img_width .. 'x' .. ngx.var.img_height;
		-- ָ���ü�ģʽ
		if(ngx.var.img_resize_type == '1') then
			size_str = size_str .. '!'   --ǿ�ƿ��
		elseif (ngx.var.img_resize_type == '2') then
			size_str = size_str .. '^'   --ǿ�Ƹ�	 
		elseif (ngx.var.img_resize_type == '3') then
			size_str = ' ^' .. size_str   --ǿ�ƿ�   
		else
			size_str = size_str .. ''	 --�ȱ���
		end
		
		size_str = " -resize " .. size_str 
	end
	
	-- +profile "*"  ȥ�� ICM, EXIF, IPTC ����Ϣ
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
	 
	-- ���½Ǽ�ˮӡ
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