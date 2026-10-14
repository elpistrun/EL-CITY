-- "lua\\drgbase\\modules\\string.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal

function string.DrG_Number(nb, size)
	nb = tostring(nb)
	while #nb < size do
		nb = "0"..nb
	end
	return nb
end
