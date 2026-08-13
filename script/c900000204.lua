--Dragonflymech Assault
--Aerol-8 / "mech" custom set
Duel.LoadScript("aerol8_common.lua")
local s,id=GetID()
function s.initial_effect(c)
	--Counter Trap: Tribute 1 Level 1/Rank 1/Link 1 monster you control; apply
	--effects based on the Type(s) of the tributed monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_names={id}

function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsChainNegatable(ev)
end
--The tribute is a cost, so the monster is gone by resolution. Its Types are
--captured here and carried on the effect's label.
function s.costfilter(c)
	return Aerol8.IsTier1(c) and c:IsReleasable()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	e:SetLabel(tc and tc:GetRace() or 0)
	Duel.Release(g,REASON_COST)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
--Bullets apply in printed order for every Type the tributed monster had, so a
--tri-type tribute negates AND destroys AND locks the card out for the turn.
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local race=e:GetLabel()
	local rc=re:GetHandler()
	if race&(RACE_INSECT|RACE_WINGEDBEAST)~=0 then
		Duel.NegateActivation(ev)
	end
	if race&RACE_MACHINE~=0 then
		if rc:IsRelateToEffect(re) and rc:IsDestructable() then
			Duel.Destroy(rc,REASON_EFFECT)
		end
		--"neither player can activate that card or its effect(s) this turn"
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,1))
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET|EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetTargetRange(1,1)
		e1:SetLabel(rc:GetCode())
		e1:SetValue(s.aclimit)
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.aclimit(e,re,tp)
	return re:GetHandler():IsCode(e:GetLabel())
end
