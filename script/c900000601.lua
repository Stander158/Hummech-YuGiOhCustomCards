--Bionic Lab Aerol-8
--Aerol-8 / "mech" custom set
Duel.LoadScript("aerol8_common.lua")
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(s.actop)
	c:RegisterEffect(e1)
	--Your "Hummech"/"Dragonflymech"/"Butterflymech" monster effects become
	--Quick Effects.
	--
	--This registration does nothing on its own: it only publishes a
	--player-targeted flag keyed to this card's passcode. Each affected monster
	--reads it through Aerol8.HasQuickGrant and picks which of its two cloned
	--registrations is live. That indirection is how Orcustrated Babel
	--(90351981) does it, and it is the only way the engine supports this --
	--an effect's speed is fixed in its EFFECT_TYPE_* flags at registration.
	--
	--Ranged to LOCATION_FZONE, so the grant dies with the card.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(id)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(1,0)
	c:RegisterEffect(e2)
	--Up to twice per turn, if a monster is Summoned: Xyz/Link Summon 1 WIND
	--Level 1/Rank 1/Link 1 monster
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	--EFFECT_FLAG_DELAY is essential here, not cosmetic: without it the trigger
	--can only activate at the immediate timing, so a Summon that happens in the
	--middle of another effect's resolution -- e.g. Ayers activating this card
	--and then Special Summoning itself in the same resolution -- misses it.
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(2,id)
	e3:SetCondition(s.chaincon)
	e3:SetTarget(s.sumtg)
	e3:SetOperation(s.sumop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
	local e5=e3:Clone()
	e5:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e5)
	--During the End Phase: shuffle this card to the Deck, then discard down to
	--1 card in hand, then optionally Set 1 archetype Spell/Trap from the Deck
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,2))
	e6:SetCategory(CATEGORY_TODECK+CATEGORY_HANDES)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e6:SetCode(EVENT_PHASE+PHASE_END)
	e6:SetRange(LOCATION_FZONE)
	e6:SetCountLimit(1)
	e6:SetOperation(s.epop)
	c:RegisterEffect(e6)
end
s.listed_series={SET_HUMMECH,SET_DRAGONFLYMECH,SET_BUTTERFLYMECH}
s.listed_names={id}

--"For the rest of the turn, you cannot activate monster effects, except
--Level 1/Rank 1/Link 1 monsters' effects (Even if this card leaves the field)."
--Registered to the player with no range, so it outlives the card -- unlike the
--Quick Effect grant above, which is deliberately bound to LOCATION_FZONE.
function s.actop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET|EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	e1:SetValue(s.aclimit)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.aclimit(e,re,tp)
	return re:IsMonsterEffect() and not Aerol8.IsTier1(re:GetHandler())
end

--"Fusion/Xyz/Link Summon 1 WIND Level 1/Rank 1/Link 1 monster."
--
--Xyz and Link have engine predicates (IsXyzSummonable / IsLinkSummonable).
--Fusion has none, so the check is spelled out from documented primitives
--against a Polymerization-style pool of your hand and field.
--
--Fusion.SummonEffFilter does exactly this and would be shorter, but it is an
--internal of proc_fusion_spell.lua rather than public API -- and that file
--lives in script/, which the auto-updater replaces. CheckFusionMaterial and
--IsCanBeSpecialSummoned are both documented and stable.
function s.fusionmaterial(tp)
	return Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_HAND|LOCATION_MZONE,0,nil)
end
function s.sumfilter(c,e,tp,mg)
	if not (c:IsAttribute(ATTRIBUTE_WIND) and Aerol8.IsTier1(c)) then return false end
	if c:IsXyzSummonable(nil) or c:IsLinkSummonable(nil) then return true end
	return c:IsType(TYPE_FUSION)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
		and c:CheckFusionMaterial(mg,nil,tp)
end
--"but only once per chain". The twice-per-turn count and this are separate
--limits, so they cannot both live in SetCountLimit: the flag clears when the
--chain ends, which blocks a second Summon inside the same chain from
--triggering this again while still leaving the turn's second use available.
function s.chaincon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,AEROL8_FLAG_BIONIC_CHAIN)==0
end
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_EXTRA,0,1,nil,
			e,tp,s.fusionmaterial(tp))
	end
	Duel.RegisterFlagEffect(tp,AEROL8_FLAG_BIONIC_CHAIN,RESET_CHAIN,0,1)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	local mg=s.fusionmaterial(tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.sumfilter,tp,LOCATION_EXTRA,0,1,1,nil,
		e,tp,mg):GetFirst()
	if not tc then return end
	if tc:IsType(TYPE_LINK) then
		Duel.LinkSummon(tp,tc,nil)
	elseif tc:IsType(TYPE_XYZ) then
		Duel.XyzSummon(tp,tc,nil)
	else
		local mat=Duel.SelectFusionMaterial(tp,tc,mg,nil,tp)
		if not mat or #mat==0 then return end
		tc:SetMaterial(mat)
		Duel.SendtoGrave(mat,REASON_EFFECT|REASON_MATERIAL|REASON_FUSION)
		Duel.BreakEffect()
		Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
	end
end

function s.setfilter(c)
	return c:IsSpellTrap() and Aerol8.IsCoreFamily(c) and c:IsSSetable()
end
function s.epop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
	--Discard until you have 1 card in your hand
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)-1
	local discarded=0
	if ct>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
		local dg=Duel.SelectMatchingCard(tp,Card.IsDiscardable,tp,LOCATION_HAND,0,ct,ct,nil)
		if #dg>0 then
			discarded=Duel.SendtoGrave(dg,REASON_EFFECT|REASON_DISCARD)
		end
	end
	if discarded>0 and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local sg=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #sg>0 then Duel.SSet(tp,sg) end
	end
	--"You cannot Set cards after this effect resolves until the end of this turn."
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,4))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET|EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SSET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
