--Quadratic Equation Cannon
--Aerol-8 / "mech" custom set
--
--The name is the specification: with X the selected monster's Level/Rank/Link
--Rating and S the banished Synchro's Level, the card computes
--
--    (X - S) * X   =   X^2 - S*X
--
--a quadratic in X, and then subtracts every card in both hands and on both
--fields. The result has to land exactly on the Link Rating of a banished Link
--monster, so this is a puzzle card: it does nothing until the board arithmetic
--is arranged to make it work.
Duel.LoadScript("aerol8_common.lua")
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_TOHAND+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end

--"Level, Rank or Link Rating", the one number this card reads off a monster.
--GetLink and GetRank both return 0 for a monster that has neither, so the type
--has to pick the accessor rather than falling back on a non-zero test.
function s.value(c)
	if c:IsType(TYPE_LINK) then return c:GetLink() end
	if c:IsType(TYPE_XYZ) then return c:GetRank() end
	return c:GetLevel()
end

--The face-down banish is the COST -- everything after the semicolon is the
--effect -- so it is paid on activation and the flip happens on resolution.
--Those are separate timings: between them the opponent can see that a card was
--banished but not which, and only the resolution reveals it.
--
--The card is remembered on the effect because the resolution has to turn that
--same one face-up, and because a face-up banished Link is exactly what the
--last clause can return -- the card paid as the cost may be the card that
--comes back.
function s.costfilter(c)
	return c:IsType(TYPE_LINK) and c:IsAbleToRemoveAsCost(POS_FACEDOWN)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_EXTRA,0,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	--KeepAlive: the group has to survive from cost to operation.
	e:SetLabelObject(g:KeepAlive())
	Duel.Remove(g,POS_FACEDOWN,REASON_COST)
end

--Only the cost gates activation. The printed text names no other requirement,
--so a board with no Synchro in the Extra Deck and no monster on the other side
--can still activate this and have it do nothing -- which is what the text says
--happens.
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_EXTRA)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_REMOVED)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,0,tp,0)
end

function s.synfilter(c)
	return c:IsType(TYPE_SYNCHRO) and c:IsAbleToRemove()
end
--"1 banished Link monster ... with its Link Rating equal to" -- face-up only,
--since a face-down banished card's rating cannot be read. This is why the cost
--flips face-up first.
function s.retfilter(c,rating)
	return c:IsFaceup() and c:IsType(TYPE_LINK) and c:GetLink()==rating
		and c:IsAbleToExtra()
end

function s.op(e,tp,eg,ep,ev,re,r,rp)
	--"the banished monster becomes face-up"
	--
	--There is no API for turning a banished card face-up and no shipped card
	--that does it (ChangePosition is battle position, which a banished card
	--does not have). Re-banishing it face-up is what the core supports:
	--card::is_removeable does not exclude a card already in LOCATION_REMOVED,
	--and field::send_to honours the position argument when the destination is
	--LOCATION_REMOVED, with no early-out for a same-location move.
	local cg=e:GetLabelObject()
	local link=cg and cg:GetFirst() or nil
	if cg then
		cg:DeleteGroup()
		e:SetLabelObject(nil)
	end
	if link and link:IsLocation(LOCATION_REMOVED) and link:IsPosition(POS_FACEDOWN) then
		Duel.Remove(link,POS_FACEUP,REASON_EFFECT)
	end

	--"then banish 1 Synchro monster from your Extra Deck"
	local sg=Duel.GetMatchingGroup(s.synfilter,tp,LOCATION_EXTRA,0,nil)
	if #sg==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local sc=sg:Select(tp,1,1,nil):GetFirst()
	if not sc then return end
	--Read the Level before banishing; the value the arithmetic uses is the one
	--the monster had when it was chosen.
	local synchro_level=sc:GetLevel()
	Duel.Remove(sc,POS_FACEUP,REASON_EFFECT)

	--"and choose 1 face-up monster your opponent controls"
	--
	--The text says face-up, which is also the shipped convention for reading
	--Level/Rank/Link off a monster (see Aerol8.IsTier1Faceup, after Spright Jet
	--13533678): a face-down monster's Level is hidden, and choosing one would
	--decide the whole equation on information the players cannot see.
	local og=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	if #og==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,0))
	local oc=og:Select(tp,1,1,nil):GetFirst()
	if not oc then return end

	--(X - S) * X, then minus every card in both hands and on both fields.
	local x=s.value(oc)
	local product=(x-synchro_level)*x
	local onboard=Duel.GetFieldGroupCount(tp,LOCATION_HAND|LOCATION_ONFIELD,
		LOCATION_HAND|LOCATION_ONFIELD)
	local rating=product-onboard

	--"Return 1 banished Link monster ... with its Link Rating equal to"
	--A Link Rating is at least 1, so a result of 0 or less matches nothing and
	--the effect stops here -- as does a result no banished Link monster has.
	if rating<1 then return end
	local rg=Duel.GetMatchingGroup(s.retfilter,tp,LOCATION_REMOVED,0,nil,rating)
	if #rg==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
	local rc=rg:Select(tp,1,1,nil)
	--"and if you do" -- the rest only happens if the return actually resolved.
	if Duel.SendtoDeck(rc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)==0 then return end

	--"add as many cards your opponent controls to your hand as possible,
	--then banish the rest face-down"
	local fg=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,nil)
	if #fg>0 then
		Duel.SendtoHand(fg,tp,REASON_EFFECT)
	end
	--Re-read the field rather than filtering the group above: what is left is
	--whatever the hand step could not move, including anything that stayed put.
	local rest=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	if #rest>0 then
		Duel.Remove(rest,POS_FACEDOWN,REASON_EFFECT)
	end
end
