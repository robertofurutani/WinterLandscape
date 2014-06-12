--Efeitos de transição
function transFade (item, delay, tempo )
	 item.alpha=0
	 transition.to( item, {delay=delay, time=tempo, alpha=1, transition=easing.inOutQuad })
end

function transFade (item, delay, tempo, funcOnComplete )
	 item.alpha=0
	 transition.to( item, {delay=delay, time=tempo, alpha=1, transition=easing.inOutQuad, onComplete=funcOnComplete })
end