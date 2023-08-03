from workbench import classifier


def test_bert_classifier():
    text = """DEA Operation Last Mile Disrupts Fentanyl Trafficking Fueled by the Sinaloa and Jalisco Cartels
The Drug Enforcement Administration announced today the results of a year-long national operation, “Operation Last Mile,” targeting the trafficking of fentanyl and methamphetamine within the United States driven by the Sinaloa and Jalisco Cartels.

“The results of this operation – over 3,000 arrests and the seizure of almost 44 million fentanyl pills – demonstrate the Justice Department’s unrelenting commitment to working with our state and local partners to keep fentanyl out of our communities and save American lives,” said Attorney General Merrick B. Garland.

“The Sinaloa and Jalisco Cartels use multi-city distribution networks, violent local street gangs, and individual dealers across the United States to flood American communities with fentanyl and methamphetamine, drive addiction, fuel violence, and kill Americans,” said DEA Administrator Milgram. “What is also alarming — American social media platforms are the means by which they do so. The Cartels use social media and encrypted platforms to run their operations and reach out to victims, and when their product kills Americans, they simply move on to try to victimize the millions of other Americans who are social media users.”

Operation Last Mile comprised 1,436 investigations conducted from May 1, 2022, through May 1, 2023, in collaboration with federal, state and local law enforcement partners, and resulted in 3,337 arrests and the seizure of nearly 44 million fentanyl pills, more than 6,500 pounds of fentanyl powder, more than 91,000 pounds of methamphetamine, 8,497 firearms, and more than $100 million.  The fentanyl powder and pill seizures equate to nearly 193 million deadly doses of fentanyl removed from communities across the United States, which have prevented countless potential drug poisoning deaths. 

Among these investigations, more than 1,100 cases involved social media applications and encrypted communications platforms, including Facebook, Instagram, TikTok, Snapchat, WhatsApp, Telegram, Signal, Wire, and Wickr."""

    labels = classifier.run_multilabel_transformer_based_classifier(
        text, "bert-base-uncased"
    )
    assert "Drug Trafficking" in labels


def test_finbert_classifier():
    text = """'An indictment was unsealed today in the District of New Mexico charging a former candidate for the New Mexico House of Representatives for a shooting spree targeting the homes of four elected officials. According to court documents, Solomon Peña, 40, ran for District 14 of the New Mexico House of Representatives during the November 2022 mid-term elections. After his November 2022 electoral defeat, Peña allegedly organized the shootings on the homes of two Bernalillo County commissioners and two New Mexico state legislators. The shootings, one of which involved a machine gun, were carried out between Dec. 4, 2022, and Jan. 3, with assistance from co-conspirators Demetrio Trujillo, 41; Jose Trujillo, 22; and others. Before the shootings, Peña visited the homes of at least three Bernalillo County commissioners and allegedly urged them not to certify the election results, claiming that the election had been “rigged” against him. Following the Bernalillo County board of commissioners’ certification of the vote, Peña allegedly hired others to conduct the shootings and carried out at least one of the shootings himself. At least three of the shootings occurred while children and other relatives of the victims were at home. “There is no room in our democracy for politically motivated violence, especially when it is used to undermine election results,” said Assistant Attorney General Kenneth A. Polite, Jr. of the Justice Department’s Criminal Division. “As alleged, Solomon Peña orchestrated four shootings at the homes of elected officials, in part because of their refusal to overturn his election defeat. Such violent actions target not only the homes and families of elected officials, but also our election system as a whole. The department will not hesitate to hold individuals accountable for acts of politically motivated violence.” “In America, the integrity of our voting system is sacrosanct,” said U.S. Attorney Alexander M.M. Uballez for the District of New Mexico. “These charges strike at the heart of our democracy. Voters, candidates, and election officials must be free to exercise their rights and do their jobs safely and free from fear, intimidation, or influence, and with confidence that law enforcement and prosecuting offices will lead the charge when someone tries to silence the will of the people. To those who try to sow division, chaos, and fear into our democratic process, these charges should send a message that we are unified, organized, and undaunted.” “The FBI and our partners are committed to ensuring violent crime investigations remain a priority,” said Assistant Director Luis Quesada of the FBI’s Criminal Investigative Division. “We will continue to pursue justice in cases like these in the name of safety for the American people.” Peña, Demetrio Trujillo, and Jose Trujillo are charged with conspiracy, interference with federally protected activities, and several firearms offenses, including the use of a machine gun. If convicted, Peña faces a mandatory minimum of 60 years in prison. Jose Trujillo was also charged with possession with intent to distribute fentanyl and firearms offenses, including possession of a machine gun. The FBI and the Albuquerque Police Department investigated the case. Senior Litigation Counsel Victor R. Salgado of the Criminal Division’s Public Integrity Section and Assistant U.S. Attorneys Jeremy Peña and Patrick E. Cordova for the District of New Mexico are prosecuting the case. An indictment is merely an allegation. All defendants are presumed innocent until proven guilty beyond a reasonable doubt in a court of law."""

    labels = classifier.run_multilabel_transformer_based_classifier(
        text, "ProsusAI-finbert"
    )
    assert "Violent Crime" in labels