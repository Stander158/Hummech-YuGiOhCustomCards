--Hummech Sabotager "Telethia"
--Aerol-8 / "mech" custom set
Duel.LoadScript("aerol8_common.lua")
local s,id=GetID()
function s.initial_effect(c)
	Aerol8.InstallTrackers()
	--(Quick Effect) If your opponent has added a card from their Deck by a
	--card effect this turn: Special Summon this card, also your opponent
	--cannot draw by card effects this turn. Once per Duel.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_DUEL)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--If an effect is activated by an Insect monster: Normal Summon this card
	--from your hand immediately after that effect resolves
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.sumcon)
	e2:SetTarget(s.sumtg)
	e2:SetOperation(s.sumop)
	c:RegisterEffect(e2)
end
s.listed_names={id}

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Aerol8.HasAddedFromDeck(1-tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
	--Your opponent cannot draw cards by card effects this turn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET|EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_DRAW)
	e1:SetTargetRange(0,1)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	s.applylock(c,tp)
end

--"(Except during the Damage Step)". There is no Duel.IsDamageStep; the Damage
--Step spans two phases and both have to be excluded.
function s.sumcon(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
	return ph~=PHASE_DAMAGE and ph~=PHASE_DAMAGE_CAL
		and re:IsMonsterEffect() and re:GetHandler():IsRace(RACE_INSECT)
end
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsSummonable(false,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,c,1,tp,0)
end
--The text says "Normal Summon this card" with no clause making it additional,
--so it spends your Normal Summon for the turn and requires one to be available.
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsSummonable(false,nil) then
		Duel.Summon(tp,c,false,nil)
	end
	s.applylock(c,tp)
end

--"You cannot Special Summon monsters, except Level 1/Rank 1/Link 1 monsters,
--the turn you use either effect of this card."
function s.applylock(c,tp)
	Aerol8.LockSpecialSummon(c,tp,aux.Stringid(id,3))
end
