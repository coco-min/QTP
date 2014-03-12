'''SourceXMLAction

Set conn=CreateObject("Adodb.Connection")
const strconn="DSN=EHRDB;UserID=ehr;Password=ehr123890;Server=10.161.145.49;"
Set adorecordset=CreateObject("Adodb.recordset")
Set adostream=CreateObject("Adodb.stream") 
Dim sourcetable,tartime,tarrole
sourcetable=Environment("table")
tartime=Environment("timeway")
sql1="select * from MEDEVENT_HISTORY where EHRID='8cea3852-dfac-4120-a080-e80fac007064'"
conn.open strconn
adorecordset.open sql1,conn,3,3 
adorecordset.Movefirst
If  adorecordset.eof=false  Then
	For k=0 to adorecordset.recordCount-1 
          If  adorecordset.Fields(2).value="8"   and  adorecordset.Fields(7).value=tartime  Then 
                      medid=adorecordset.Fields(0).value
					  uptime=adorecordset.Fields(12).value
					  createtime=adorecordset.Fields(11).value
					  Exit For
          End If
		  adorecordset.MoveNext
	Next
End If
Environment("id")=medid
Set adores=CreateObject("Adodb.recordset")
Set adostream=CreateObject("Adodb.stream") 
sql2="select  ATTRIBUTE_VALUE  from EVENT_ATTRIBUTE where MEDEVENTID="&medid&""
adores.open sql2,conn,2,2

If  Not adores.EOF Then   
			  adostream.Open 
              adostream.Type=1
			 Dim attributeValue 
	      	 attributeValue =  adores.Fields("ATTRIBUTE_VALUE")  
             adostream.write attributeValue
             adostream.SaveToFile "d:\dx.xml",2
End If


Dim arrstr,arrcol
arrstr=""
Dim strXML,reg,match,strnode
Set reg=new RegExp
reg.IgnoreCase=True
reg.pattern="^\d{4}-\d{2}-\d{2}$"

'''spacexml "d:\dx.xml","TestResult"               
'''trasferXml "d:\test.xml","TestResult"  
'''GetXml "d:\test.xml","

trasferXml "d:\dx.xml","TestResult"
spacexml "d:\test.xml","TestResult"   
GetXml "d:\test.xml","TestResult"   

arrtag=split(trim(strnode),"!")
arr=split(trim(strXML),"!")                 
                                                                                                                                                                                                                                    
For i=lbound(arr) to ubound(arr)
If arr(i)<>" "  Then
  If i<>lbound(arr) Then
	  arrstr=arrstr+"$"
  End If
  arrstr=arrstr&arr(i)
End If
Next

arrvalue=split(arrstr,"$")
For k=1to ubound(arrvalue)+1
	If InStr(1,arrvalue(k-1),"+") Then
	arrlast=split(arrvalue(k-1),"+")
	Set match=reg.Execute(arrlast(0))
	If (CInt(match.Count)>=1) Then
          arrvalue(k-1)=arrlast(0)
		  else
		  For n=0 to ubound(arrlast)
          arrcol=arrcol&arrlast(n)&"+"
		    Next
		  arrvalue(k-1)=left(arrcol,len(arrcol)-1)
	End If
   End If               
 Next

 Call assignment7()


Function spacexml(ByVal strXmlFilePath,ByVal xmlNodeName)
   Dim xmlDoc,xmlRoot   
		Set doc = XMLUtil.CreateXML()                                                                                           
         doc.LoadFile strXmlFilePath 
         strfirst=doc.ToString     
		 spacestr=split(strfirst,"</")
		Dim reg,mac
		set reg=new RegExp
		reg.IgnoreCase=True
'''		reg.pattern="^[A-Za-z]+[0-9]*[_]*[A-Za-z]*[0-9]*>\s*<[A-Za-z]+[0-9]*[_]*[A-Za-z]*[0-9]*>\s*$"
	    reg.pattern="^[A-Za-z]+[0-9]*[_]*[A-Za-z]*[0-9]*>\s* <*[A-Za-z]*[0-9]*[_]*[A-Za-z]*[0-9]*>*\s*<[A-Za-z]+[0-9]*[_]*[A-Za-z]*[0-9]*>\s*$"
		For k=0 to ubound(spacestr)
           Set mac=reg.Execute(spacestr(k))
	       If (Cint(mac.count)>=1) Then
			       For i=1 to  len(spacestr(k))
                         m=mid(spacestr(k),i,1)
						 If m=" "  Then
							 m=""
						 End If
						 spa=spa&m
					Next
					spacestr(k)=spa
					spacestr(k)=spacestr(k)&"?0?"
	       End If
		   str=str&spacestr(k)&"</"
		Next
	     str=left(str,len(str)-2)
	      Set ADO_stream=CreateObject("Adodb.stream")
				   X=Cstr(str)  
				   With ADO_stream
				    .Type=2                                                                                                                                 ' 设置Stream 对象中的数据的类型为文本类型
				   .Mode=3                                                                                                                                   '3表示修改数据的权限是可读可写
				    .open
				   .WriteText  X                                                                                                                           ' 把字符数据写到一个文本 Stream 对象
				   .SaveToFile "d:\test.xml",2                                                                                                '将去除单标签节点的字符串存到xml，格式是utf-8的格式
				   End with   		   
End Function


Function trasferXml (ByVal strXmlFilePath,ByVal xmlNodeName)
        Dim xmlDoc,xmlRoot   
		Set doc = XMLUtil.CreateXML()
         doc.LoadFile strXmlFilePath 
		 numOfDescendants = doc.GetRootElement().GetNumDescendantElemByName("slotName") 
		 Environment("numOfDescendants")=numOfDescendants
        str=doc.ToString
		arraystr=split(str,">")
          Dim regdel,matches
         set regdel=new RegExp
        regdel.IgnoreCase=True
		regdel.pattern="^\s*<[A-Za-z]+[0-9]*[_]*[A-Za-z]*[0-9]*\s*/$"
		For m=0 to ubound(arraystr)
            Set matches=regdel.Execute(arraystr(m))
                  If (CInt(matches.Count)>=1) Then 
					arraystr(m)=""
				 end if
				 If arraystr(m)="" Then
					 strlink=strlink&arraystr(m)
				else
				  strlink=strlink&arraystr(m)&">"
				   End If  		  
		Next
		           Set ADO_stream=CreateObject("Adodb.stream")
				   X=Cstr(strlink)  
				   With ADO_stream
				    .Type=2
				   .Mode=3
				    .open
				   .WriteText  X
				   .SaveToFile "d:\test.xml",2
				   End with   		   
End Function

Function GetXml (ByVal strXmlFilePath,ByVal xmlNodeName)
        Dim xmlDoc,xmlRoot   
        Set xmlDoc = CreateObject("Microsoft.XMLDOM")
        xmlDoc.async = False
        xmlDoc.load strXmlFilePath
        If xmlDoc.parseError.errorCode <> 0 Then
                MsgBox "XML文件格式不对，原因是：" & Chr(13) &  xmlDoc.parseError.reason
                Exit Function                
        End If
        Set xmlRoot = xmlDoc.documentElement
		Call rTravel(xmlRoot )
        GetXml = True '  
End Function

Sub rTravel (rNode)
Dim ilen,i,child,childtext,k,sum
Dim a()
        iLen = rNode.childNodes.length
        If iLen > 0 Then
                For i = 0 To rNode.childNodes.length -1
                        Set child = rNode.childNodes.item(i)
                    If child.haschildnodes=true  Then
                        On Error Resume Next 
						For k=0 to child.childNodes.length-1
						Set sonchild=child.childNodes.item(k)
						If  sonchild.haschildnodes=false Then 	   
                            nodena=child.NodeName 	   
							  If nodena="assessment"  Then
                                        parnodena=child.parentnode.NodeName
										 nodena=parnodena&"->"&nodena
                                   End If  							   
						      strnode=strnode&nodena&"!"			   				  
						End If
					  Next  		
					End If  	
                        Call rTravel(child)
						            Next				             						
                        childtext = child.nodeValue
						spb=Instr(1,childtext,"?0?")
                                   If spb<>0 Then
                                              childtext="?0?"
                                    End If
                        strXML =strXML&childtext &" !"
        Else
                Exit sub
        End If
End sub



Function assignment7()
   gender=Environment("gender")
   If gender="1" Then
	   tarfd="400"
	elseif gender="2"   Then
	   tarfd="300"
   End If
   flw001="SBP(NA/SN)"
   flw002="DBP(NA/SN)"
   flw003="当前体重(NA/SN)"
   flw004="目标体重(NA/SN)"
   flw005="当前体质指数(NA/SN)"
   flw006="目标体质指数(NA/SN)"
   flw007="当前心率(NA/SN)"
   flw008="目标心率(NA/SN)"
   flw009="当前日吸烟量(NA/SN)"
   flw090="目标日吸烟量(NA/SN)"
   flw010="当前日饮酒量(NA/SN)"
   flw091="目标日饮酒量(NA/SN)"
   flw011="当前运动频率(NA/SN)"
   flw012="当前运动时间(NA/SN)"
   flw013="当前主食(NA/SN)"
   flw092="目标主食(NA/SN)"
	flw014="当前摄盐情况(NA/SN)"
	flw016="空腹血糖(NA/SN)"
	flw017="餐后血糖(NA/SN)"
	flw018="糖化血红蛋白(NA/SN)"
	flw019="血脂（mmol/L）：TC（总胆固醇）(NA/SN)"
	flw020="血脂（mmol/L）：TG（甘油三脂）(NA/SN)"
	flw021="血脂（mmol/L）：LDL-c（低密度脂蛋白）(NA/SN)"
	flw022="血脂（mmol/L）：HDL-c（高密度脂蛋白）(NA/SN)"
	flw023="肾功（mmol/L）：BUN（尿素氮）(NA/SN)"
    flw024="肾功（mmol/L）：Cr（尿肌酐）(NA/SN)"
    flw025="肾功（mmol/L）：CCr（肌酐清除率）(NA/SN)"
    flw026="尿检(NA/SN)"
    flw027="尿微量白蛋白(NA/SN)"
    flw028="心电图(NA/SN)"
    flw029="眼底(NA/SN)"
   flwvalue01="-1"
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(13)=flw001
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(13)= flwvalue01
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(14)=flw002
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(14)= flwvalue01
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(15)=flw003
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(15)= flwvalue01
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(16)=flw004
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(16)= flwvalue01
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(17)=flw005
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(17)= flwvalue01
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(18)=flw006
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(18)= flwvalue01
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(19)=flw007
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(19)= flwvalue01
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(20)=flw008
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(20)= flwvalue01
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(23)=flw009
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(23)= flwvalue01
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(24)=flw090
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(24)= flwvalue01
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(25)=flw010
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(25)= flwvalue01
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(26)=flw091
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(26)= flwvalue01
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(27)=flw011
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(27)= flwvalue01
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(29)=flw012
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(29)= flwvalue01
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(31)=flw013
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(31)= flwvalue01
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(32)=flw092
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(32)=tarfd
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(33)=flw014
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(33)= flwvalue01
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(43)=flw016
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(43)= flwvalue01
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(44)=flw017
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(44)= flwvalue01
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(45)=flw018
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(45)= flwvalue01
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(47)=flw019
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(47)= flwvalue01
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(48)=flw020
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(48)= flwvalue01 
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(49)=flw021
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(49)= flwvalue01
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(50)=flw022
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(50)= flwvalue01
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(51)=flw023
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(51)= flwvalue01
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(52)=flw024
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(52)= flwvalue01
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(53)=flw025
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(53)= flwvalue01
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(54)=flw026
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(54)= flwvalue01
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(55)=flw027
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(55)= flwvalue01
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(56)=flw028
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(56)= flwvalue01
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(57)=flw029
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(57)= flwvalue01
   
   flw030="随访医生签名(NA/SN)"
   flwvalue02="不详"
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(68)=flw030
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(68)=flwvalue02

   flw031="此次随访分类-血糖(NA/SN)"
   flw032="此次随访分类-血压(NA/SN)"
   flw033="症状(NA/SN)"
   flw034="药物不良反应(NA/SN)"
   flwvalue03="1"
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(11)=flw033
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(11)=",1,"
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(60)=flw034
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(60)=flwvalue03
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(64)=flw031
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(64)=flwvalue03
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(63)=flw032
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(63)=flwvalue03
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(21)="足背动脉搏动(NA/SN)"
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(21)="2"
   flw036="服药依从性(NA/SN)"
   flwvalue04="4"
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(59)=flw036
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(59)=flwvalue04
    flw037="其他辅助检查(NA/SN)"
   flwvalue05="无"
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(58)=flw037
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(58)=flwvalue05
   flw040="转诊原因(NA/SN)"
   flw041="转诊机构及科别(NA/SN)"
   flw042="冗余生活方式指导-吸烟量(NA/SN)"
   flw043="冗余生活方式指导-饮酒量(NA/SN)"
   flw044="冗余生活方式指导-运动(NA/SN)"
   flw045="冗余生活方式指导-主食(NA/SN)"
   flw046="冗余生活方式指导-摄盐(NA/SN)"
   flwvalue06="?0?"
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(65)=flw040
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(65)=flwvalue06
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(66)=flw041
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(66)=flwvalue06
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(35)=flw042
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(35)=flwvalue06
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(36)=flw043
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(36)=flwvalue06
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(37)=flw044
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(37)=flwvalue06
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(38)=flw045
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(38)=flwvalue06
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(39)=flw046
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(39)=flwvalue06
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(11)="症状"
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(11)=",1,"
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(28)="目标运动频率"
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(28)="7"
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(30)="目标运动时间"
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(30)="30"

   

   onesign=Environment("numOfDescendants")
Dim k,s,t
k=s=t=0
Dim arrary(30)
Dim illness(30)
Dim thersign(30)
Dim arrother(30)
Dim  symt(30)
Dim symother(30)
Dim plus(30)
Dim  tempother(30)
Dim tempname(30)
Dim AA
AA=array("收缩压","舒张压","体重","BMI","心率","足背动脉","身高","腰围","臀围","腰/臀","体温","脉搏","呼吸","眼底","心电图","尿蛋白或微量白蛋白","尿检","CCr","肌酐清除率","Cr","尿素氮[BUN]","高密度脂蛋白[HDL-c]","低密度脂蛋白[LDL-c]","甘油三脂[TG]","总胆固醇[TC]","糖化血红蛋白","餐后血糖","空腹血糖")

For q=0 to ubound(arrtag)
Dim strempty,cin,sport
cin=false
sport=false
glod=False
strempty=""
If  arrtag(q)="dateCreated" Then
     seat=Instr(1,arrvalue(q),":") 
	If seat<>0 Then
        arrvalue(q)=left(Trim(arrvalue(q)),10)
	End If
	arrvalue(q)=Cdate(arrvalue(q))
	 timetemp=Trim(arrvalue(q))
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(4)="随访日期"
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(4)=arrvalue(q)
 elseif arrtag(q)="chronicEval->assessment"  Then
               For p=1 to len(Trim(arrvalue(q)))
				   post=Mid(Trim(arrvalue(q)),p,1)
				    If post=","  or post="、"  Then
                         cin=true
						 Exit  For
					End If	 
			   Next    
			 If cin=true Then
				 chronic=split(Trim(arrvalue(q)),post)
				 For g=0 to ubound(chronic)
                      If chronic(g)<>"糖尿病" and  chronic(g)<>"高血压病" and chronic(g)<>"高血压" Then
                              illname=illname&chronic(g)&","
					  End If
					  If chronic(g)="冠心病"  Then
                              arrary(k)="4"
					  elseif  chronic(g)="脑卒中"  Then
                              arrary(k)="5"	   
					  elseif  chronic(g)="肿瘤"  Then
                              arrary(k)="6"		     
					   elseif   chronic(g)="精神病" Then
                              arrary(k)="7"		 
					 elseif  chronic(g)="高脂血症"  Then
                              arrary(k)="8"		 
					elseif  chronic(g)="慢性阻塞性肺疾病"  Then
                              arrary(k)="9"		 
					elseif  chronic(g)="癫痫"  Then
                              arrary(k)="10"		 	  
				    elseif  chronic(g)="痛风"  Then
                              arrary(k)="11"	
					 elseif  chronic(g)="哮喘"  Then
                              arrary(k)="12"	
					 elseif  chronic(g)="骨关节炎"  or chronic(g)="关节病" Then
                              arrary(k)="13"	    	              	    	  		   		      		  		   	  
					  End If
					  If arrary(k)<>""  Then
                             chronictype=chronictype&arrary(k)&","  
					  End If 				
					k=k+1
				 Next
			elseif cin=false  Then
			    	  If Trim(arrvalue(q))="冠心病"  Then
                              arrary(k)="4"
					  elseif  Trim(arrvalue(q))="脑卒中"  Then
                              arrary(k)="5"	   
					  elseif  Trim(arrvalue(q))="肿瘤"  Then
                              arrary(k)="6"		     
					   elseif  Trim(arrvalue(q))="精神病"  Then
                              arrary(k)="7"		 
					 elseif  Trim(arrvalue(q))="高脂血症"  Then
                              arrary(k)="8"		 
					elseif  Trim(arrvalue(q))="慢性阻塞性肺疾病"  Then
                              arrary(k)="9"		 
					elseif  Trim(arrvalue(q))="癫痫"  Then
                              arrary(k)="10"		 	  
				    elseif  Trim(arrvalue(q))="痛风"  Then
                              arrary(k)="11"	
					 elseif  Trim(arrvalue(q))="哮喘"  Then
                              arrary(k)="12"	
					 elseif  Trim(arrvalue(q))="骨关节炎" or   Trim(arrvalue(q))="关节病" Then
                              arrary(k)="13"	  		     	    	  		   		      		  		   	  
					  End If
					  If  arrary(k)<>"" Then
                             chronictype=chronictype&arrary(k)&"," 
					  End If	         
			 End If
			 If illname=""  Then
                     DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(7)="其他慢病合并症名称"
	                 DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(7)="无"
			else
			         DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(7)="其他慢病合并症名称"
	                 DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(7)=","&illname 		 
			 End If
             If  chronictype="" Then
                   DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(6)="其他慢病合并症"
	               DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(6)=",1,"
			else
			       DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(6)="其他慢病合并症"
                   DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(6)=","&chronictype
			 End If 	 
  elseif arrtag(q)="care_visit_type" Then
    DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(10)=arrtag(q)
    DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(10)=arrvalue(q)
  elseif arrtag(q)="symptom" Then
        y=y+1
      If Trim(arrvalue(q))="无症状" Then
		  symt(y)="1"
	  elseif Trim(arrvalue(q))="头痛头晕" Then
		  symt(y)="2"
	  elseif Trim(arrvalue(q))="恶心呕吐" Then
		  symt(y)="3"
	 elseif Trim(arrvalue(q))="眼花耳鸣" Then
		  symt(y)="4"
	 elseif Trim(arrvalue(q))="呼吸困难" Then
		  symt(y)="5"
	 elseif Trim(arrvalue(q))="心悸胸闷" Then
		  symt(y)="6"
     elseif Trim(arrvalue(q))="鼻衄出血不止" Then
		  symt(y)="7"
     elseif Trim(arrvalue(q))="四肢发麻" Then
		  symt(y)="8"
     elseif Trim(arrvalue(q))="下肢水肿" Then
		  symt(y)="9"
     elseif Trim(arrvalue(q))="多饮" Then
		  symt(y)="10"
     elseif Trim(arrvalue(q))="多食" Then
		  symt(y)="11"
     elseif Trim(arrvalue(q))="多尿" Then
		  symt(y)="12"
     elseif Trim(arrvalue(q))="视力模糊" Then
		  symt(y)="13"
    elseif Trim(arrvalue(q))="感染" Then
		 symt(y)="14"
    elseif Trim(arrvalue(q))="手脚麻木" Then
		  symt(y)="15"
    elseif Trim(arrvalue(q))="体重明显下降" Then
		  symt(y)="16"       	  
	 elseif Trim(arrvalue(q))="null" or Trim(arrvalue(q))="NULL"  or Trim(arrvalue(q))="undefined" or Trim(arrvalue(q))="?0?"Then
		  symt(y)="1"
	 else
	      symother(y)=Trim(arrvalue(q))
		  symt(y)="17"
          other=other&symother(y)&","
	      DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(12)="其他症状"
          DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(12)=","&  other
	  End If
	  If  symt(y)>=2  and  symt(y)<=17  Then     
		     If   symt(y)="17" Then
				     sevenum=sevenum+1
			         If  sevenum=1 Then
                            medstr=medstr&symt(y)&","  
			         End If
            else
			          medstr=medstr&symt(y)&","   
			 End If	                                                                                                                                                  
			  DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(11)="症状"
              DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(11)=","& medstr
     End If  	 
  elseif arrtag(q)="slotName" And Trim(arrvalue(q))="收缩压" Then
    If arrtag(q+1)="slotValue" Then
         If  arrvalue(q+1)="?0?"  or Trim(arrvalue(q+1))="NULL" or Trim(arrvalue(q+1))="null" or Trim(arrvalue(q+1))="undefined" Then
	          arrvalue(q+1)="-1"
          End If
               checkstr=Instr(1,arrvalue(q+1),"/")
          If checkstr<>0 Then
                losestr=split(Trim(arrvalue(q+1)),"/")
                firstva=losestr(0)
          else
               firstva=Trim(arrvalue(q+1))
         End If
         	  For x=1 to Len(firstva)
                     str=Mid(firstva,x,1)
                           If str>="0" And str<="9" Then
                                strempty=strempty&str
	                       End If
                              arrvalue(q+1)=strempty
               Next   
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(13)=Trim(arrvalue(q))
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(13)=arrvalue(q+1)
  End If
elseif arrtag(q)="slotName" And Trim(arrvalue(q))="舒张压" Then
    If arrtag(q+1)="slotValue" Then
     If arrvalue(q+1)="?0?"  or Trim(arrvalue(q+1))="NULL" or Trim(arrvalue(q+1))="null" or Trim(arrvalue(q+1))="undefined" Then
		arrvalue(q+1)="-1"
     End If
	checkstr=Instr(1,arrvalue(q+1),"/")
	If checkstr<>0 Then
        losestr=split(Trim(arrvalue(q+1)),"/")
	    firstva=losestr(0)
   else
       firstva=Trim(arrvalue(q+1))
  end if
	  For x=1 to Len(firstva)
		  str=Mid(firstva,x,1)
		  If str>="0" And str<="9" Then
            strempty=strempty&str
		  End If
          arrvalue(q+1)=strempty
	  Next
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(14)=Trim(arrvalue(q))
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(14)=arrvalue(q+1)
  End If	
 elseif arrtag(q)="slotName" And Trim(arrvalue(q))="体重" Then
   If arrtag(q+1)="slotValue" Then
     If  arrvalue(q+1)="?0?"  or Trim(arrvalue(q+1))="NULL" or Trim(arrvalue(q+1))="null" or Trim(arrvalue(q+1))="undefined" Then
		arrvalue(q+1)="-1"
     End If
     checkstr=Instr(1,Trim(arrvalue(q+1)),"/")
	If checkstr<>0 Then
	    losestr=split(Trim(arrvalue(q+1)),"/")
	    firstva=losestr(0)
    else
	   firstva=Trim(arrvalue(q+1))
    End If
	  For x=1 to Len(firstva)
		  str=Mid(firstva,x,1)
		  If str>="0" And str<="9" Then
            strempty=strempty&str
		  End If
          arrvalue(q+1)=strempty
	  Next
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(15)="当前体重"
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(15)=arrvalue(q+1)
      End If
elseif arrtag(q)="slotName" And Trim(arrvalue(q))="体重" Then
  If arrtag(q+1)="slotValue" Then
	checkstr=Instr(1,arrvalue(q+1),"/")
	If checkstr<>0 Then
        losestr=split(Trim(arrvalue(q+1)),"/")
	    firstva=losestr(1)
    else
        firstva="-1"
    End if
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(16)="目标体重"
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(16)=firstva
  End If
elseif arrtag(q)="slotName" And Trim(arrvalue(q))="BMI" Then
    If arrtag(q+1)="slotValue" Then
     If  arrvalue(q+1)="?0?"  or Trim(arrvalue(q+1))="NULL" or Trim(arrvalue(q+1))="null" or Trim(arrvalue(q+1))="undefined" Then
		arrvalue(q+1)="-1"
     End If
	checkstr=Instr(1,arrvalue(q+1),"/")
	If checkstr<>0 Then
        losestr=split(Trim(arrvalue(q+1)),"/")
        firstva=losestr(0)
    else
        firstva=Trim(arrvalue(q+1))
   end if
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(17)="当前体质指数（BMI）"
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(17)=firstva
  End If
elseif arrtag(q)="slotName" And Trim(arrvalue(q))="BMI" Then
    If arrtag(q+1)="slotValue" Then
	checkstr=Instr(1,arrvalue(q+1),"/")
	If checkstr<>0 Then
        losestr=split(Trim(arrvalue(q+1)),"/")
	    firstva=losestr(1)
   else
       firstva="-1"
  End If
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(18)="目标体质指数（BMI）"
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(18)=firstva
  End If
elseif arrtag(q)="slotName" And Trim(arrvalue(q))="心率" Then
    If arrtag(q+1)="slotValue" Then
     If  arrvalue(q+1)="?0?"  or Trim(arrvalue(q+1))="NULL" or Trim(arrvalue(q+1))="null" or Trim(arrvalue(q+1))="undefined" Then
		arrvalue(q+1)="-1"
     End If
	checkstr=Instr(1,arrvalue(q+1),"/")
	If checkstr<>0 Then
	    losestr=split(Trim(arrvalue(q+1)),"/")
       firstva=losestr(0)
    else
       firstva=Trim(arrvalue(q+1))
    End if
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(19)="当前心率"
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(19)=firstva
  End If
 elseif arrtag(q)="slotName" And Trim(arrvalue(q))="心率" Then
    If arrtag(q+1)="slotValue" Then
	checkstr=Instr(1,arrvalue(q+1),"/")
	If checkstr<>0 Then
	    losestr=split(Trim(arrvalue(q+1)),"/")
       firstva=losestr(1)
    else
       firstva="-1"
    End if
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(20)="目标心率"
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(20)=firstva
  End If 
 elseif arrtag(q)="slotName" And Trim(arrvalue(q))="足背动脉" Then
     If arrtag(q+1)="slotValue" Then
         If  arrvalue(q+1)="?0?"  or Trim(arrvalue(q+1))="NULL" or Trim(arrvalue(q+1))="null" or Trim(arrvalue(q+1))="undefined" Then
	           arrvalue(q+1)="2"
         End If
		 If Trim(arrvalue(q+1))="触及"  or  Trim(arrvalue(q+1))="可触及" or  Trim(arrvalue(q+1))="可及" or Trim(arrvalue(q+1))="正常" Then
			 arrvalue(q+1)="2"
		elseif Trim(arrvalue(q+1))="未触及"  Then
			 arrvalue(q+1)="1"
		 End If
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(21)="足背动脉搏动"
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(21)= arrvalue(q+1)
  End If 
 elseif arrtag(q)="slotName"   Then
     If Trim(arrvalue(q))="身高" or Trim(arrvalue(q))="腰围"  or Trim(arrvalue(q))="臀围"  or Trim(arrvalue(q))="腰/臀" or Trim(arrvalue(q))="体温"  or Trim(arrvalue(q))="脉搏" or Trim(arrvalue(q))="呼吸"   Then
	         ka=ka+1
			 If arrtag(q+1)="slotValue" and (Trim(arrvalue(q+1))<>""  or Trim(arrvalue(q+1))<>"null" or Trim(arrvalue(q+1))<>"NULL" or Trim(arrvalue(q+1))<>"undefined")  Then   		
		           thersign(ka)=Trim(arrvalue(q))&":"&Trim(arrvalue(q+1))
                   vital=vital&thersign(ka)&";" 	
			  End If         
			If vital<>""  Then
                  vital=left(vital,len(vital)-1)
	       End If     
	 End If	 
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(22)="其他体征"
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(22)=vital
 elseif arrtag(q)="interventionType" And Trim(arrvalue(q))="日吸烟量" Then
   If arrtag(q+1)="interventionInfo" Then
	    arrsmok=split(Trim(arrvalue(q+1)),"|")
        If  arrsmok(2)="支" Then
	                 If arrsmok(0)="" or arrsmok(0)="null" or arrsmok(0)="NULL" or arrsmok(0)="undefined" Then
		                  newsmok="-1"
				    	  DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(23)="当前日吸烟量"
                         DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(23)=newsmok
	                  End If
	                 If arrsmok(1)="" or arrsmok(1)="null" or arrsmok(1)="NULL" or arrsmok(1)="undefined" Then
	                         tarsmok="-1"
						    DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(24)="目标日吸烟量"
                            DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(24)=tarsmok
                     End If
                       n=len(arrsmok(0))
                	   For i=1 to n
                             ns=Mid(arrsmok(0),i,1)
	                   		If ns>="0" and ns<="9"  Then
			                        	s1=s1+1
			                        	If s1=n Then
                                                  DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(23)="当前日吸烟量"
                                                  DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(23)=arrsmok(0)
			                        	End If               
			            	else
							             DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(23)="当前日吸烟量"
                                         DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(23)="-1"
		                          	     DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(35)="冗余生活方式指导-吸烟量"
                                         DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(35)=arrsmok(0)&"/"&arrsmok(1)&"("&arrsmok(2)&")"
		                	End If
	                  Next
                       m=len(arrsmok(1))
	                  For i=1 to m
                            ts=Mid(arrsmok(1),i,1)
		                 	If ts>="0" and ts<="9"  Then
			                         	 t1=t1+1
			                        	 If t1=m Then   				
                                                   DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(24)="目标日吸烟量"
                                                   DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(24)=arrsmok(1)
					                     End If
			                  else
							               DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(24)="目标日吸烟量"
                                           DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(24)="-1"
			                               DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(35)="冗余生活方式指导-吸烟量"
                                           DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(35)=arrsmok(0)&"/"&arrsmok(1)&"("&arrsmok(2)&")"
			                  End If
		                Next		  
			else
			       n=len(arrsmok(0))
                	   For i=1 to n
                             ns=Mid(arrsmok(0),i,1)
	                   		If ns>="0" and ns<="9"  Then
			                        	s1=s1+1
			                        	If s1=n Then
                                                  DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(23)="当前日吸烟量"
                                                  DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(23)=arrsmok(0)
			                        	End If               
			            	else
							             DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(23)="当前日吸烟量"
                                         DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(23)="-1"
		                          	     DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(35)="冗余生活方式指导-吸烟量"
                                         DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(35)=arrsmok(0)&"/"&arrsmok(1)&"("&arrsmok(2)&")"
		                	End If
	                  Next
                       m=len(arrsmok(1))
	                  For i=1 to m
                            ts=Mid(arrsmok(1),i,1)
		                 	If ts>="0" and ts<="9"  Then
			                         	 t1=t1+1
			                        	 If t1=m Then   				
                                                   DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(24)="目标日吸烟量"
                                                   DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(24)=arrsmok(1)
					                     End If
			                  else
							               DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(24)="目标日吸烟量"
                                           DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(24)="-1"
			                               DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(35)="冗余生活方式指导-吸烟量"
                                           DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(35)=arrsmok(0)&"/"&arrsmok(1)&"("&arrsmok(2)&")"
			                  End If
		                Next		  
			     DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(35)="冗余生活方式指导-吸烟量"
                 DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(35)=arrsmok(0)&"/"&arrsmok(1)&"("&arrsmok(2)&")"
       End If
   End If

  elseif arrtag(q)="interventionType" And Trim(arrvalue(q))="日饮酒量" Then
   If arrtag(q+1)="interventionInfo" Then
	    arrdrink=split(Trim(arrvalue(q+1)),"|")
        If  arrdrink(2)="两" Then
	                 If arrdrink(0)="" or arrdrink(0)="null" or arrdrink(0)="NULL" or arrdrink(0)="undefined" Then
		                  newdrink="-1"
				    	  DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(25)="当前日饮酒量"
                         DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(25)=newdrink
	                  End If
	                 If arrdrink(1)="" or arrdrink(1)="null" or arrdrink(1)="NULL" or arrdrink(1)="undefined" Then
	                        tardrink="-1"
						    DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(26)="目标日饮酒量"
                            DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(26)=tardrink
                     End If
                       z=len(arrdrink(0))
                	   For i=1 to z
                             ns=Mid(arrdrink(0),i,1)
	                   		If ns>="0" and ns<="9"  Then
			                        	s2=s2+1
			                        	If s2=z Then
                                                  DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(25)="当前日饮酒量"
                                                  DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(25)=arrdrink(0)
			                        	End If               
			            	else
							             DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(25)="当前日饮酒量"
                                         DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(25)="-1"
										 DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(36)="冗余生活方式指导-饮酒量"
                                         DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(36)=arrdrink(0)&"/"&arrdrink(1)&"("&arrdrink(2)&")"
		                	End If
	                  Next
                       v=len(arrdrink(1))
	                  For i=1 to v
                            ts=Mid(arrdrink(1),i,1)
		                 	If ts>="0" and ts<="9"  Then
			                         	 t2=t2+1
			                        	 If t2=v Then   				
                                                   DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(26)="目标日饮酒量"
                                                   DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(26)=arrdrink(1)
					                     End If
			                  else
							               DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(26)="目标日饮酒量"
                                           DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(26)="-1"
										   DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(36)="冗余生活方式指导-饮酒量"
                                           DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(36)=arrdrink(0)&"/"&arrdrink(1)&"("&arrdrink(2)&")"
			                  End If
		                Next		  
			else
			      z=len(arrdrink(0))
                	   For i=1 to z
                             ns=Mid(arrdrink(0),i,1)
	                   		If ns>="0" and ns<="9"  Then
			                        	s2=s2+1
			                        	If s2=z Then
                                                  DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(25)="当前日饮酒量"
                                                  DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(25)=arrdrink(0)
			                        	End If               
			            	else
							             DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(25)="当前日饮酒量"
                                         DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(25)="-1"
										 DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(36)="冗余生活方式指导-饮酒量"
                                         DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(36)=arrdrink(0)&"/"&arrdrink(1)&"("&arrdrink(2)&")"
		                	End If
	                  Next
                       v=len(arrdrink(1))
	                  For i=1 to v
                            ts=Mid(arrdrink(1),i,1)
		                 	If ts>="0" and ts<="9"  Then
			                         	 t2=t2+1
			                        	 If t2=v Then   				
                                                   DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(26)="目标日饮酒量"
                                                   DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(26)=arrdrink(1)
					                     End If
			                  else
							               DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(26)="目标日饮酒量"
                                           DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(26)="-1"
										   DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(36)="冗余生活方式指导-饮酒量"
                                           DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(36)=arrdrink(0)&"/"&arrdrink(1)&"("&arrdrink(2)&")"
			                  End If
		                Next		  
			     DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(36)="冗余生活方式指导-饮酒量"
                 DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(36)=arrdrink(0)&"/"&arrdrink(1)&"("&arrdrink(2)&")"
       End If
   End If

 elseif arrtag(q)="interventionType" And Trim(arrvalue(q))="运动" Then
   If arrtag(q+1)="interventionInfo" Then   
	      arrsport=split(Trim(arrvalue(q+1)),"|")
        If  arrsport(2)="次/周,分钟/次" Then
	                 If arrsport(0)="" or arrsport(0)="null" or arrsport(0)="NULL" or arrsport(0)="undefined" Then
		                 newsport="-1"
				    	 DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(27)="当前运动频率"
                         DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(27)=newsport
						 DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(29)="当前运动时间"
                         DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(29)=newsport
	                  End If
	                 If arrsport(1)="" or arrsport(1)="null" or arrsport(1)="NULL" or arrsport(1)="undefined" Then
	                       sportfre="7"
						   sporttime="30"
						    DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(28)="目标运动频率"
                            DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(28)=sportfre
							DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(30)="目标运动时间"
                            DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(30)=sporttime
                     End If
                For k=1 to len(arrsport(0))
	                        pos=Mid(arrsport(0),k,1)
							If pos=","  Then
								    sport=True
								    Exit For
							else
								    sport=false 							
							End If
				Next			
	                        If sport=True Then
                                 freq=split(arrsport(0),pos)
                                 nr=len(freq(0))
                                  For i=1 to nr
                                        ns=Mid(freq(0),i,1)
	                            		If ns>="0" and ns<="9"  Then
			                                   	s3=s3+1
			                                    If s3=nr Then
                                                      DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(27)="当前运动频率"
                                                      DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(27)=freq(0)
			                                    End If             									        
			                        	else
									           DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(27)="当前运动频率"
                                               DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(27)="-1"
		                          	           DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(37)="冗余生活方式指导-运动"
                                               DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(37)=arrsport(0)&"/"&arrsport(1)&"("&arrsport(2)&")"
		                              End If
	                             Next

                                     cr=len(freq(1))
                                     For i=1 to cr
                                           ns=Mid(freq(1),i,1)
	                            	       If ns>="0" and ns<="9"  Then
			                                        	s4=s4+1
			                                 	  If s4=cr Then
                                                        DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(29)="当前运动时间"
                                                        DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(29)=freq(1)
			                                      End If             									        
			                        	else
									            DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(29)="当前运动时间"
                                                DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(29)="-1"
		                          	            DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(37)="冗余生活方式指导-运动"
                                                 DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(37)=arrsport(0)&"/"&arrsport(1)&"("&arrsport(2)&")"
		                               End If
	                               Next
					elseif sport=false Then
							        zr=len(arrsport(0))
                            	   For i=1 to zr
                                          ns=Mid(arrsport(0),i,1)
	                             		If ns>="0" and ns<="9"  Then
			                                      	s5=s5+1
			                                	If s5=zr Then
                                                           DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(27)="当前运动频率"
                                                           DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(27)=arrsport(0)
														   DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(29)="当前运动时间"
                                                           DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(29)="-1"
			                                 	End If               
			                        	else
										          DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(27)="当前运动频率"
                                                  DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(27)="-1"
											      DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(29)="当前运动时间"
                                                  DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(29)="-1"
		                                	      DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(37)="冗余生活方式指导-运动"
                                                  DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(37)=arrsport(0)&"/"&arrsport(1)&"("&arrsport(2)&")"
		                            	End If
	                               Next						
	                       End If
  
             
                    For k=1 to len(arrsport(1))
	                        getcom=Mid(arrsport(1),k,1)
							If getcom=","  Then
								 glod=True
								 Exit For
							else
							    glod=False	 
							End If
			       Next			
	                        If glod=True   Then
                                 tim=split(arrsport(1),pos)
                                 mr=len(tim(0))
                                  For i=1 to mr
                                        ns=Mid(tim(0),i,1)
	                            		If ns>="0" and ns<="9"  Then
			                                   	s6=s6+1
			                             	If s6=mr Then
                                                  DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(28)="目标运动频率"
                                                  DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(28)=tim(0)
			                               End If             									        
			                        	else
										 DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(28)="目标运动频率"
                                         DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(28)="7"
		                          	     DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(37)="冗余生活方式指导-运动"
                                         DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(37)=arrsport(0)&"/"&arrsport(1)&"("&arrsport(2)&")"
		                              End If
	                             Next

                                dr=len(tim(1))
                                  For i=1 to dr
                                        ns=Mid(tim(1),i,1)
	                            		If ns>="0" and ns<="9"  Then
			                                   	s7=s7+1
			                             	If s7=dr Then
                                                  DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(30)="目标运动时间"
                                                  DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(30)=tim(1)
			                               End If             									        
			                        	else
									     DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(30)="目标运动时间"
                                         DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(30)="30"
		                          	     DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(37)="冗余生活方式指导-运动"
                                         DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(37)=arrsport(0)&"/"&arrsport(1)&"("&arrsport(2)&")"
		                              End If
	                             Next
							elseif glod=False     Then
							        dz=len(arrsport(1))
                            	   For i=1 to dz
                                          ns=Mid(arrsport(1),i,1)
	                             		If ns>="0" and ns<="9"  Then
			                                      	s8=s8+1
			                                	If s8=dz Then
                                                           DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(28)="目标运动频率"
                                                           DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(28)=arrsport(1)
														   DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(30)="目标运动时间"
                                                           DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(30)="30"
			                                 	End If               
			                        	else
										          DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(28)="目标运动频率"
                                                  DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(28)="7"
											      DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(30)="目标运动时间"
                                                  DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(30)="30"
		                                	      DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(37)="冗余生活方式指导-运动"
                                                  DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(37)=arrsport(0)&"/"&arrsport(1)&"("&arrsport(2)&")"
		                            	End If
	                               Next						
	                       End If
	else                                                                                                                          '这个else是匹配单位的分支
			    For k=1 to len(arrsport(0))
	                        pos=Mid(arrsport(0),k,1)
							If pos=","  Then
								    sport=True
								    Exit For
							else
								    sport=false 							
							End If
				Next			
	                        If sport=True Then
                                 freq=split(arrsport(0),pos)
                                 nr=len(freq(0))
                                  For i=1 to nr
                                        ns=Mid(freq(0),i,1)
	                            		If ns>="0" and ns<="9"  Then
			                                   	s3=s3+1
			                                    If s3=nr Then
                                                      DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(27)="当前运动频率"
                                                      DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(27)=freq(0)
			                                    End If             									        
			                        	else
									           DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(27)="当前运动频率"
                                               DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(27)="-1"
		                          	           DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(37)="冗余生活方式指导-运动"
                                               DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(37)=arrsport(0)&"/"&arrsport(1)&"("&arrsport(2)&")"
		                              End If
	                             Next

                                     cr=len(freq(1))
                                     For i=1 to cr
                                           ns=Mid(freq(1),i,1)
	                            	       If ns>="0" and ns<="9"  Then
			                                        	s4=s4+1
			                                 	  If s4=cr Then
                                                        DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(29)="当前运动时间"
                                                        DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(29)=freq(1)
			                                      End If             									        
			                        	else
									            DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(29)="当前运动时间"
                                                DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(29)="-1"
		                          	            DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(37)="冗余生活方式指导-运动"
                                                 DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(37)=arrsport(0)&"/"&arrsport(1)&"("&arrsport(2)&")"
		                               End If
	                               Next
							elseif sport=false Then
							        zr=len(arrsport(0))
                            	   For i=1 to zr
                                          ns=Mid(arrsport(0),i,1)
	                             		If ns>="0" and ns<="9"  Then
			                                      	s5=s5+1
			                                	If s5=zr Then
                                                           DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(27)="当前运动频率"
                                                           DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(27)=arrsport(0)
														   DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(29)="当前运动时间"
                                                           DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(29)="-1"
			                                 	End If               
			                        	else
										          DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(27)="当前运动频率"
                                                  DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(27)="-1"
											      DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(29)="当前运动时间"
                                                  DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(29)="-1"
		                                	      DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(37)="冗余生活方式指导-运动"
                                                  DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(37)=arrsport(0)&"/"&arrsport(1)&"("&arrsport(2)&")"
		                            	End If
	                               Next						
	                       End If
						          For k=1 to len(arrsport(1))
	                        pos=Mid(arrsport(1),k,1)
	                        If pos="," Then
                                 tim=split(arrsport(1),pos)
                                 mr=len(tim(0))
                                  For i=1 to mr
                                        ns=Mid(tim(0),i,1)
	                            		If ns>="0" and ns<="9"  Then
			                                   	s6=s6+1
			                             	If s6=mr Then
                                                  DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(28)="目标运动频率"
                                                  DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(28)=tim(0)
			                               End If             									        
			                        	else
										 DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(28)="目标运动频率"
                                         DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(28)="7"
		                          	     DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(37)="冗余生活方式指导-运动"
                                         DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(37)=arrsport(0)&"/"&arrsport(1)&"("&arrsport(2)&")"
		                              End If
	                             Next

                                dr=len(tim(1))
                                  For i=1 to dr
                                        ns=Mid(tim(1),i,1)
	                            		If ns>="0" and ns<="9"  Then
			                                   	s7=s7+1
			                             	If s7=dr Then
                                                  DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(30)="目标运动时间"
                                                  DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(30)=tim(1)
			                               End If             									        
			                        	else
									     DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(30)="目标运动时间"
                                         DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(30)="30"
		                          	     DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(37)="冗余生活方式指导-运动"
                                         DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(37)=arrsport(0)&"/"&arrsport(1)&"("&arrsport(2)&")"
		                              End If
	                             Next
							Exit For
							elseif pos<>","   Then
							        dz=len(arrsport(1))
                            	   For i=1 to dz
                                          ns=Mid(arrsport(1),i,1)
	                             		If ns>="0" and ns<="9"  Then
			                                      	s8=s8+1
			                                	If s8=dz Then
                                                           DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(28)="目标运动频率"
                                                           DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(28)=arrsport(1)
														   DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(30)="目标运动时间"
                                                           DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(30)="30"
			                                 	End If               
			                        	else
										          DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(28)="目标运动频率"
                                                  DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(28)="7"
											      DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(30)="目标运动时间"
                                                  DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(30)="30"
		                                	      DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(37)="冗余生活方式指导-运动"
                                                  DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(37)=arrsport(0)&"/"&arrsport(1)&"("&arrsport(2)&")"
		                            	End If
	                               Next						
	                       End If
		              Next 	   
		                  DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(37)="冗余生活方式指导-运动"
                          DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(37)=arrsport(0)&"/"&arrsport(1)&"("&arrsport(2)&")"   
		End If				 
 End If
  elseif arrtag(q)="interventionType" And Trim(arrvalue(q))="主食" Then
   If arrtag(q+1)="interventionInfo" Then
	    arrfood=split(Trim(arrvalue(q+1)),"|")
        If  arrfood(2)="克/天" Then
	                 If arrfood(0)="" or arrfood(0)="null" or arrfood(0)="NULL" or arrfood(0)="undefined" Then
		                 newfood="-1"
				    	  DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(31)="当前主食"
                         DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(31)=newfood
	                  End If
	                 If arrfood(1)="" or arrfood(1)="null" or arrfood(1)="NULL" or arrfood(1)="undefined" Then
	                       tarood=tarfd
						    DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(32)="目标主食"
                            DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(32)=tarood
                     End If
                       f1=len(arrfood(0))
                	   For i=1 to f1
                             ns=Mid(arrfood(0),i,1)
	                   		If ns>="0" and ns<="9"  Then
			                        	s9=s9+1
			                        	If s9=f1 Then
                                                  DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(31)="当前主食"
                                                  DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(31)=arrfood(0)
			                        	End If               
			            	else
							             DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(31)="当前主食"
                                         DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(31)="-1"
		                          	     DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(38)="冗余生活方式指导-主食"
                                         DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(38)=arrfood(0)&"/"&arrfood(1)&"("&arrfood(2)&")"
		                	End If
	                  Next
                       f2=len(arrfood(1))
	                  For i=1 to f2
                            ts=Mid(arrfood(1),i,1)
		                 	If ts>="0" and ts<="9"  Then
			                         	 w=w+1
			                        	 If w=f2 Then   				
                                                   DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(32)="目标主食"
                                                   DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(32)=arrfood(1)
					                     End If
			                  else 
							               DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(32)="目标主食"
                                           DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(32)=tarfd
			                               DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(38)="冗余生活方式指导-主食"
                                           DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(38)=arrfood(0)&"/"&arrfood(1)&"("&arrfood(2)&")"
			                  End If
		                Next		  
			else
			       f1=len(arrfood(0))
                	   For i=1 to f1
                             ns=Mid(arrfood(0),i,1)
	                   		If ns>="0" and ns<="9"  Then
			                        	s9=s9+1
			                        	If s9=f1 Then
                                                  DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(31)="当前主食"
                                                  DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(31)=arrfood(0)
			                        	End If               
			            	else
							             DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(31)="当前主食"
                                         DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(31)="-1"
		                          	     DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(38)="冗余生活方式指导-主食"
                                         DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(38)=arrfood(0)&"/"&arrfood(1)&"("&arrfood(2)&")"
		                	End If
	                  Next
                       f2=len(arrfood(1))
	                  For i=1 to f2
                            ts=Mid(arrfood(1),i,1)
		                 	If ts>="0" and ts<="9"  Then
			                         	 w=w+1
			                        	 If w=f2 Then   				
                                                   DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(32)="目标主食"
                                                   DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(32)=arrfood(1)
					                     End If
			                  else 
							               DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(32)="目标主食"
                                           DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(32)=tarfd
			                               DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(38)="冗余生活方式指导-主食"
                                           DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(38)=arrfood(0)&"/"&arrfood(1)&"("&arrfood(2)&")"
			                  End If
		                Next		  
			     DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(38)="冗余生活方式指导-主食"
                 DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(38)=arrfood(0)&"/"&arrfood(1)&"("&arrfood(2)&")"
       End If
 End If
  elseif arrtag(q)="interventionType" And Trim(arrvalue(q))="摄盐" Then
   If arrtag(q+1)="interventionInfo" Then
	    arrsalt=split(Trim(arrvalue(q+1)),"|")
        If  arrsalt(2)="克/天" Then
	                 If arrsalt(0)="" or arrsalt(0)="null" or arrsalt(0)="NULL" or arrsalt(0)="undefined" Then
		                 newsalt="-1"
				    	  DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(33)="当前摄盐情况"
                         DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(33)=newsalt
	                  End If
	                 If arrsalt(1)="" or arrsalt(1)="null" or arrsalt(1)="NULL" or arrsalt(1)="undefined" Then
	                       tarsalt="6"
						    DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(34)="目标摄盐情况"
                            DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(34)=tarsalt
                     End If
                       g=len(arrsalt(0))
                	   For i=1 to g
                             ns=Mid(arrsalt(0),i,1)
	                   		If ns>="0" and ns<="9"  Then
			                        	w1=w1+1
			                        	If w1=g Then
                                                  DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(33)="当前摄盐情况"
                                                  DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(33)=arrsalt(0)
			                        	End If               
			            	else
							             DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(33)="当前摄盐情况"
                                         DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(33)="-1"
		                          	     DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(39)="冗余生活方式指导-摄盐"
                                         DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(39)=arrsalt(0)&"/"&arrsalt(1)&"("&arrsalt(2)&")"
		                	End If
	                  Next
                       g1=len(arrsalt(1))
	                  For i=1 to g1
                            ts=Mid(arrsalt(1),i,1)
		                 	If ts>="0" and ts<="9"  Then
			                         	 w2=w2+1
			                        	 If w2=g1 Then   				
                                                   DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(34)="目标摄盐情况"
                                                   DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(34)=arrsalt(1)
					                     End If
			                  else							             
							               DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(34)="目标摄盐情况"
                                           DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(34)="6"
			                               DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(39)="冗余生活方式指导-摄盐"
                                           DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(39)=arrsalt(0)&"/"&arrsalt(1)&"("&arrsalt(2)&")"
			                  End If
		                Next		  
			else
			      g=len(arrsalt(0))
                	   For i=1 to g
                             ns=Mid(arrsalt(0),i,1)
	                   		If ns>="0" and ns<="9"  Then
			                        	w1=w1+1
			                        	If w1=g Then
                                                  DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(33)="当前摄盐情况"
                                                  DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(33)=arrsalt(0)
			                        	End If               
			            	else
							             DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(33)="当前摄盐情况"
                                         DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(33)="-1"
		                          	     DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(39)="冗余生活方式指导-摄盐"
                                         DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(39)=arrsalt(0)&"/"&arrsalt(1)&"("&arrsalt(2)&")"
		                	End If
	                  Next
                       g1=len(arrsalt(1))
	                  For i=1 to g1
                            ts=Mid(arrsalt(1),i,1)
		                 	If ts>="0" and ts<="9"  Then
			                         	 w2=w2+1
			                        	 If w2=g1 Then   				
                                                   DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(34)="目标摄盐情况"
                                                   DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(34)=arrsalt(1)
					                     End If
							 else							             
							               DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(34)="目标摄盐情况"
                                           DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(34)="6"
			                               DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(39)="冗余生活方式指导-摄盐"
                                           DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(39)=arrsalt(0)&"/"&arrsalt(1)&"("&arrsalt(2)&")"
			                  End If
		                Next		  
			     DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(39)="冗余生活方式指导-摄盐"
                 DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(39)=arrsalt(0)&"/"&arrsalt(1)&"("&arrsalt(2)&")"
       End If
 End If

  elseif arrtag(q)="habitType" and Trim(arrvalue(q))="7"  Then
     If arrtag(q+1)="behaviorDesc1" Then
		 If Trim(arrvalue(q+1))="良好"  Then
                  arrvalue(q+1)="1"
		elseif Trim(arrvalue(q+1))="一般"  Then
                  arrvalue(q+1)="2"
		 elseif Trim(arrvalue(q+1))="差"  Then
                  arrvalue(q+1)="3"
		 End If
      DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(41)="心理调整"
      DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(41)=arrvalue(q+1) 	 
  End If
   elseif arrtag(q)="habitType" and Trim(arrvalue(q))="8"  Then
     If arrtag(q+1)="behaviorDesc1" Then
		 If Trim(arrvalue(q+1))="良好"  Then
                  arrvalue(q+1)="1"
		elseif Trim(arrvalue(q+1))="一般"  Then
                  arrvalue(q+1)="2"
		 elseif Trim(arrvalue(q+1))="差"  Then
                  arrvalue(q+1)="3"
		 End If
      DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(42)="遵医行为"
      DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(42)=arrvalue(q+1) 	 
  End If

 End If
 
if arrtag(q)="slotName" And Trim(arrvalue(q))="空腹血糖" Then                                                                                                                
   If arrtag(q+1)="slotValue" Then
     If  arrvalue(q+1)="?0?"  or Trim(arrvalue(q+1))="NULL" or Trim(arrvalue(q+1))="null" or Trim(arrvalue(q+1))="undefined" Then
		arrvalue(q+1)="-1"
     End If
     checkstr=Instr(1,Trim(arrvalue(q+1)),"/")
	If checkstr<>0 Then
	    losestr=split(Trim(arrvalue(q+1)),"/")
	    firstva=losestr(0)
    else
	   firstva=Trim(arrvalue(q+1))
    End If
	  For x=1 to Len(firstva)
		  str=Mid(firstva,x,1)
		  If str>="a" And str<="z"  or str>="A" And str<="Z"  Then
			  str=""
            strempty=strempty&str
			else
			strempty=strempty&str
		  End If
          arrvalue(q+1)=strempty
	  Next
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(43)="空腹血糖"
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(43)=arrvalue(q+1)
      End If
 elseif arrtag(q)="slotName" And Trim(arrvalue(q))="餐后血糖" Then
   If arrtag(q+1)="slotValue" Then
     If  arrvalue(q+1)="?0?"  or Trim(arrvalue(q+1))="NULL" or Trim(arrvalue(q+1))="null" or Trim(arrvalue(q+1))="undefined" Then
		arrvalue(q+1)="-1"
     End If
     checkstr=Instr(1,Trim(arrvalue(q+1)),"/")
	If checkstr<>0 Then
	    losestr=split(Trim(arrvalue(q+1)),"/")
	    firstva=losestr(0)
    else
	   firstva=Trim(arrvalue(q+1))
    End If
	  For x=1 to Len(firstva)
		  str=Mid(firstva,x,1)
		  If str>="a" And str<="z"  or str>="A" And str<="Z"  Then
			  str=""
            strempty=strempty&str
			else
			strempty=strempty&str
		  End If
          arrvalue(q+1)=strempty
	  Next
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(44)="餐后血糖"
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(44)=arrvalue(q+1)
      End If
 elseif arrtag(q)="slotName" And Trim(arrvalue(q))="糖化血红蛋白" Then
   If arrtag(q+1)="slotValue" Then
     If  arrvalue(q+1)="?0?"  or Trim(arrvalue(q+1))="NULL" or Trim(arrvalue(q+1))="null" or Trim(arrvalue(q+1))="undefined" Then
		arrvalue(q+1)="-1"
     End If
     checkstr=Instr(1,Trim(arrvalue(q+1)),"/")
	If checkstr<>0 Then
	    losestr=split(Trim(arrvalue(q+1)),"/")
	    firstva=losestr(0)
    else
	   firstva=Trim(arrvalue(q+1))
    End If
	  For x=1 to Len(firstva)
		  str=Mid(firstva,x,1)
		  If str>="a" And str<="z"  or str>="A" And str<="Z"  or str="%"  Then
			  str=""
            strempty=strempty&str
			else
			strempty=strempty&str
		  End If
          arrvalue(q+1)=strempty
	  Next
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(45)="糖化血红蛋白"
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(45)=arrvalue(q+1)
      End If
 elseif arrtag(q)="slotName" And Trim(arrvalue(q))="总胆固醇[TC]" Then
   If arrtag(q+1)="slotValue" Then
     If  arrvalue(q+1)="?0?"  or Trim(arrvalue(q+1))="NULL" or Trim(arrvalue(q+1))="null" or Trim(arrvalue(q+1))="undefined" Then
		arrvalue(q+1)="-1"
     End If
     checkstr=Instr(1,Trim(arrvalue(q+1)),"/")
	If checkstr<>0 Then
	    losestr=split(Trim(arrvalue(q+1)),"/")
	    firstva=losestr(0)
    else
	   firstva=Trim(arrvalue(q+1))
    End If
	  For x=1 to Len(firstva)
		  str=Mid(firstva,x,1)
		  If str>="a" And str<="z"  or str>="A" And str<="Z"   Then
			  str=""
            strempty=strempty&str
			else
			strempty=strempty&str
		  End If
          arrvalue(q+1)=strempty
	  Next
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(47)="血脂（mmol/L）：TC（总胆固醇）"
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(47)=arrvalue(q+1)
      End If
 elseif arrtag(q)="slotName" And Trim(arrvalue(q))="甘油三脂[TG]" Then
   If arrtag(q+1)="slotValue" Then
     If  arrvalue(q+1)="?0?"  or Trim(arrvalue(q+1))="NULL" or Trim(arrvalue(q+1))="null" or Trim(arrvalue(q+1))="undefined" Then
		arrvalue(q+1)="-1"
     End If
     checkstr=Instr(1,Trim(arrvalue(q+1)),"/")
	If checkstr<>0 Then
	    losestr=split(Trim(arrvalue(q+1)),"/")
	    firstva=losestr(0)
    else
	   firstva=Trim(arrvalue(q+1))
    End If
	  For x=1 to Len(firstva)
		  str=Mid(firstva,x,1)
		  If str>="a" And str<="z"  or str>="A" And str<="Z"   Then
			  str=""
            strempty=strempty&str
			else
			strempty=strempty&str
		  End If
          arrvalue(q+1)=strempty
	  Next
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(48)="血脂（mmol/L）：TG（甘油三脂）"
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(48)=arrvalue(q+1)
      End If
 elseif arrtag(q)="slotName" And Trim(arrvalue(q))="低密度脂蛋白[LDL-c]" Then
   If arrtag(q+1)="slotValue" Then
     If  arrvalue(q+1)="?0?"  or Trim(arrvalue(q+1))="NULL" or Trim(arrvalue(q+1))="null" or Trim(arrvalue(q+1))="undefined" Then
		arrvalue(q+1)="-1"
     End If
     checkstr=Instr(1,Trim(arrvalue(q+1)),"/")
	If checkstr<>0 Then
	    losestr=split(Trim(arrvalue(q+1)),"/")
	    firstva=losestr(0)
    else
	   firstva=Trim(arrvalue(q+1))
    End If
	  For x=1 to Len(firstva)
		  str=Mid(firstva,x,1)
		  If str>="a" And str<="z"  or str>="A" And str<="Z"   Then
			  str=""
            strempty=strempty&str
			else
			strempty=strempty&str
		  End If
          arrvalue(q+1)=strempty
	  Next
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(49)="血脂（mmol/L）：LDL-c（低密度脂蛋白）"
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(49)=arrvalue(q+1)
      End If
 elseif arrtag(q)="slotName" And Trim(arrvalue(q))="高密度脂蛋白[HDL-c]" Then
   If arrtag(q+1)="slotValue" Then
     If  arrvalue(q+1)="?0?"  or Trim(arrvalue(q+1))="NULL" or Trim(arrvalue(q+1))="null" or Trim(arrvalue(q+1))="undefined" Then
		arrvalue(q+1)="-1"
     End If
     checkstr=Instr(1,Trim(arrvalue(q+1)),"/")
	If checkstr<>0 Then
	    losestr=split(Trim(arrvalue(q+1)),"/")
	    firstva=losestr(0)
    else
	   firstva=Trim(arrvalue(q+1))
    End If
	  For x=1 to Len(firstva)
		  str=Mid(firstva,x,1)
		  If str>="a" And str<="z"  or str>="A" And str<="Z"   Then
			  str=""
            strempty=strempty&str
			else
			strempty=strempty&str
		  End If
          arrvalue(q+1)=strempty
	  Next
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(50)="血脂（mmol/L）：HDL-c（高密度脂蛋白）"
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(50)=arrvalue(q+1)
      End If
 elseif arrtag(q)="slotName" And Trim(arrvalue(q))="尿素氮[BUN]" Then
   If arrtag(q+1)="slotValue" Then
     If  arrvalue(q+1)="?0?"  or Trim(arrvalue(q+1))="NULL" or Trim(arrvalue(q+1))="null" or Trim(arrvalue(q+1))="undefined" Then
		arrvalue(q+1)="-1"
     End If
     checkstr=Instr(1,Trim(arrvalue(q+1)),"/")
	If checkstr<>0 Then
	    losestr=split(Trim(arrvalue(q+1)),"/")
	    firstva=losestr(0)
    else
	   firstva=Trim(arrvalue(q+1))
    End If
	  For x=1 to Len(firstva)
		  str=Mid(firstva,x,1)
		  If str>="a" And str<="z"  or str>="A" And str<="Z"   Then
			  str=""
            strempty=strempty&str
			else
			strempty=strempty&str
		  End If
          arrvalue(q+1)=strempty
	  Next
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(51)="肾功（mmol/L）：BUN（尿素氮）"
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(51)=arrvalue(q+1)
      End If
 elseif arrtag(q)="slotName" And Trim(arrvalue(q))="Cr" Then
   If arrtag(q+1)="slotValue" Then
     If  arrvalue(q+1)="?0?"  or Trim(arrvalue(q+1))="NULL" or Trim(arrvalue(q+1))="null" or Trim(arrvalue(q+1))="undefined" Then
		arrvalue(q+1)="-1"
     End If
     checkstr=Instr(1,Trim(arrvalue(q+1)),"/")
	If checkstr<>0 Then
	    losestr=split(Trim(arrvalue(q+1)),"/")
	    firstva=losestr(0)
    else
	   firstva=Trim(arrvalue(q+1))
    End If
	  For x=1 to Len(firstva)
		  str=Mid(firstva,x,1)
		  If str>="a" And str<="z"  or str>="A" And str<="Z"   Then
			  str=""
            strempty=strempty&str
			else
			strempty=strempty&str
		  End If
          arrvalue(q+1)=strempty
	  Next
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(52)="肾功（mmol/L）：Cr（尿肌酐）"
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(52)=arrvalue(q+1)
      End If
  elseif arrtag(q)="slotName" And (Trim(arrvalue(q))="CCr" or Trim(arrvalue(q))="肌酐清除率") Then
   If arrtag(q+1)="slotValue" Then
     If  arrvalue(q+1)="?0?"  or Trim(arrvalue(q+1))="NULL" or Trim(arrvalue(q+1))="null" or Trim(arrvalue(q+1))="undefined" Then
		arrvalue(q+1)="-1"
     End If
     checkstr=Instr(1,Trim(arrvalue(q+1)),"/")
	If checkstr<>0 Then
	    losestr=split(Trim(arrvalue(q+1)),"/")
	    firstva=losestr(0)
    else
	   firstva=Trim(arrvalue(q+1))
    End If
	  For x=1 to Len(firstva)
		  str=Mid(firstva,x,1)
		  If str>="a" And str<="z"  or str>="A" And str<="Z"   Then
			  str=""
            strempty=strempty&str
			else
			strempty=strempty&str
		  End If
          arrvalue(q+1)=strempty
	  Next
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(53)="肾功（mmol/L）：CCr（肌酐清除率）"
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(53)=arrvalue(q+1)
      End If
  elseif arrtag(q)="slotName" And Trim(arrvalue(q))="尿检"  Then
   If arrtag(q+1)="slotValue" Then
     If  arrvalue(q+1)="?0?"  or Trim(arrvalue(q+1))="NULL" or Trim(arrvalue(q+1))="null" or Trim(arrvalue(q+1))="undefined" Then
		arrvalue(q+1)="-1"
     End If
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(54)="尿检"
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(54)=arrvalue(q+1)
      End If
  elseif arrtag(q)="slotName" And Trim(arrvalue(q))="尿蛋白或微量白蛋白"  Then
   If arrtag(q+1)="slotValue" Then
     If  arrvalue(q+1)="?0?"  or Trim(arrvalue(q+1))="NULL" or Trim(arrvalue(q+1))="null" or Trim(arrvalue(q+1))="undefined" Then
	      malbtemp="-1"
		  DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(55)="尿蛋白或微量白蛋白"
          DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(55)=malbtemp
	else	   
	 For mla=1 to len(Trim(arrvalue(q+1)))
		 malb=Mid(Trim(arrvalue(q+1)),mla,1)
		 If  malb>="0" and malb<="9" or malb="." Then
			   malbtemp=arrvalue(q+1)
			   DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(55)="尿蛋白或微量白蛋白"
               DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(55)=malbtemp
		else
		       malbtemp="-1"    
			   DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(55)="尿蛋白或微量白蛋白"
               DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(55)=malbtemp
			   Exit For
		 End If
	 Next
    End If
   End If
  elseif arrtag(q)="slotName" And Trim(arrvalue(q))="心电图"  Then
   If arrtag(q+1)="slotValue" Then
     If  arrvalue(q+1)="?0?"  or Trim(arrvalue(q+1))="NULL" or Trim(arrvalue(q+1))="null" or Trim(arrvalue(q+1))="undefined" Then
		arrvalue(q+1)="-1"
     End If
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(56)="心电图"
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(56)=arrvalue(q+1)
      End If
 elseif arrtag(q)="slotName" And Trim(arrvalue(q))="眼底"  Then
   If arrtag(q+1)="slotValue" Then
     If  arrvalue(q+1)="?0?"  or Trim(arrvalue(q+1))="NULL" or Trim(arrvalue(q+1))="null" or Trim(arrvalue(q+1))="undefined" Then
		arrvalue(q+1)="-1"
     End If
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(57)="眼底"
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(57)=arrvalue(q+1)
      End If
   elseif arrtag(q)="drug_compliance"  Then
      If  arrvalue(q)="?0?" or  Trim(arrvalue(q))="null" or Trim(arrvalue(q))="NULL" or Trim(arrvalue(q))="undefined"  Then
		 arrvalue(q)="4"
	 End If
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(59)="服药依从性"
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(59)=arrvalue(q)
   elseif arrtag(q)="drug_adverseness"  Then
      If  arrvalue(q)="?0?" or  Trim(arrvalue(q))="null" or Trim(arrvalue(q))="NULL" or Trim(arrvalue(q))="undefined"  or  Trim(arrvalue(q))="无"  Then
		 arrmed="1"
		 DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(61)="药物不良反应描述"
         DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(61)="?0?"
      else
	     arrmed="2"
		 DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(61)="药物不良反应描述"
         DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(61)=arrvalue(q)
	 End If
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(60)="药物不良反应"
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(60)=arrmed
  elseif arrtag(q)="hypoglycemicReaction"  Then
    DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(62)="低血糖反应"
    DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(62)=arrvalue(q)
  elseif arrtag(q)="type"  And  Trim(arrvalue(q))="1"  Then
     If arrtag(q+1)="result"  Then
           If  arrvalue(q+1)="?0?" or  Trim(arrvalue(q+1))="null" or Trim(arrvalue(q+1))="NULL" or Trim(arrvalue(q+1))="undefined"  Then
		         arrvalue(q+1)="1"
	       End If
		  DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(63)="此次随访分类-血压"
          DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(63)=arrvalue(q+1) 
	 End If
   elseif arrtag(q)="type"  And  Trim(arrvalue(q))="2"  Then
     If arrtag(q+1)="result"  Then
           If  arrvalue(q+1)="?0?" or  Trim(arrvalue(q+1))="null" or Trim(arrvalue(q+1))="NULL" or Trim(arrvalue(q+1))="undefined"  Then
		         arrvalue(q+1)="1"
	       End If
		  DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(64)="此次随访分类-血糖"
          DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(64)=arrvalue(q+1) 
	 End If
  elseif arrtag(q)="referral_reason"  Then
        If Trim(arrvalue(q))="null"  or Trim(arrvalue(q))="NULL"  or  Trim(arrvalue(q))="undefined"  Then
	         arrvalue(q)="?0?"
        End If
          DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(65)="转诊原因"
          DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(65)=arrvalue(q)
   elseif arrtag(q)="referral_authority"   Then
       arrhis=Trim(arrvalue(q))&"--"
       If  arrtag(q+1)="referral_department"  Then
		   arrhis=arrhis&Trim(arrvalue(q+1)) 
	        po=Instr(1,arrhis,"null")
	        pt=Instr(1,arrhis,"NULL")
	        pf=Instr(1,arrhis,"undefined")
            If po<>0 or pt<>0 or pf<>0 Then
                   arrhis="?0?"
	        End If
	     End If 	
		  DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(66)="转诊机构及科别"
          DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(66)=arrhis
   elseif arrtag(q)="next_visit_date"  Then
     If  arrvalue(q)="?0?" or  Trim(arrvalue(q))="null" or Trim(arrvalue(q))="NULL" or Trim(arrvalue(q))="undefined"  Then
		 arrvalue(q)=DateAdd("m",3,tartime)
		 arrvalue(q)=Cdate(arrvalue(q))
	 End If
	     arrvalue(q)=Cdate(arrvalue(q))
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(67)="下次随访日期"
   DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(67)=arrvalue(q)
   elseif arrtag(q)="doctorName" Then
        If  Trim(arrvalue(q))="?0?" or  Trim(arrvalue(q))="null" or Trim(arrvalue(q))="NULL" or Trim(arrvalue(q))="undefined"  Then
	           arrvalue(q)="不详"
       End If
	    DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(68)="随访医生签名"
        DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(68)=arrvalue(q)
End If
    
 If arrtag(q)="slotName"  Then
    For d=0 to 27
		If Trim(arrvalue(q))<>AA(d) Then
			If arrtag(q+1)="slotValue"  Then
                  tempname(na)=Trim(arrvalue(q))
		          tempother(te)=Trim(arrvalue(q+1))
			else
			      tempother(te)=""
		          tempname(na)=""  
			End If 		  
		elseif Trim(arrvalue(q))=AA(d)  Then
		      tempother(te)=""
			  tempname(na)=""
			  te=te+1
			  Exit for 
		End If	      
	 Next
	 If   tempother(te)<>"" Then
            thertest=thertest&tempname(na)&":"&tempother(te)&";"
	 End If
 End If

Next
       If thertest<>""  Then
            thertest=left(thertest,len(thertest)-1)
	        DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(58)="其他辅助检查"
            DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(58)=thertest
	   End If   
	   If uptime<>""  Then
             DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(73)="更新时间"
             DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(73)=uptime
		else
		     DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(73)="更新时间"
             DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(73)=timetemp  
	   End If
	   If createtime<>""  Then
             DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(74)="创建的系统时间"
             DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(74)=createtime  
		else
		     DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").valueByRow(74)="创建的系统时间"
             DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").valueByRow(74)=timetemp      
	   End If
End Function




'''TargetAction代码如下：



Set taconn=CreateObject("Adodb.Connection")
const tastrconn="DSN=phis_o;UID=phis;PWD=phis;DBQ=PHIS_TEL ;"
Set taresult=CreateObject("Adodb.recordset")
Dim targettable,sharetag
targettable="SVC_FLW_CHRONIC"
Environment("table")=targettable
tasql="select * from "&targettable&" where EHR_ID='8cea3852-dfac-4120-a080-e80fac007064' and ID=85605"                                                                                
taconn.open tastrconn
taresult.open tasql,taconn,3,3
taresult.MoveFirst

Call targetdata()
Public Function targetdata()
Dim n  
Dim last
last=false
Do
 Do  while not taresult.eof                                      
 On Error Resume Next
	For i=0 to taresult.Fields.count-1
	      If IsNull(taresult.Fields(i).value) or IsEmpty(taresult.Fields(i).value)  or taresult.Fields(i).value="" Then 
			 taresult.Fields(i).value="?0?"
        	End If
                     If taresult.Fields(i).name="DATE_CREATED"  Then
						 Environment("timeway")=taresult.Fields(i).value
					 End If
                     Datatable.GetSheet("TargetAction").GetParameter("targetlistname").value=taresult.Fields(i).name
                     DataTable.GetSheet("TargetAction").GetParameter("target").value=taresult.Fields(i).value
                     DataTable.GetSheet("TargetAction").SetCurrentRow(i+2)     
	Next 
	  If i=taresult.Fields.count Then
		  last=true
		  Exit Do
	  End If
Loop
Loop until  last=true
taresult.Close
taconn.Close
Set taresult=Nothing
Set taconn=Nothing
End Function





































'''CompareAction代码如下：



Call compdata()                                                                        '字符串对比函数
Public Function compdata()
Dim MyStr1, MyStr2, MyComp
Dim k,j
maxcount=DataTable.GetSheet("TargetAction").GetCurrentRow
For k=1 to maxcount
   If  DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").ValueByRow(k)<>"" Then
	MyNode=DataTable.GetSheet("SourceXMLAction").GetParameter("nodetag").ValueByRow(k)
	MyField=DataTable.GetSheet("TargetAction").GetParameter("targetlistname").ValueByRow(k)
    MyTarStr=DataTable.GetSheet("TargetAction").GetParameter("target").ValueByRow(k)
	MyStr1=DataTable.GetSheet("SourceXMLAction").GetParameter("nodeval").ValueByRow(k)
    MyXmlStr=Trim(MyStr1)
'    spb=Instr(1,MyXmlStr,vbcrlf)             '这个if是为了去除空值节点中的回车符
'      If spb<>0 Then
'           MyXmlStr=left(MyXmlStr,3)
'      End If
                 If  MyXmlStr=MyTarStr Then 
                       Reporter.ReportEvent micPass,"custom step","经对比，两个字符串内容相同。" &"源XML节点名称是：" &MyNode &"//" &"源数据转换前或转换后的值是：" &MyXmlStr &"；" &"目标字段名称是：" &MyField &"//" &"目标数据是：" &MyTarStr
                 else
                       Reporter.ReportEvent micFail,"custom step",  "经对比，两个字符串内容不相同，请检查具体原因：" &"源XML节点名称是：" &MyNode &"//" &"源数据转换前或转换后的值是：" &MyXmlStr &"；"   &"目标字段名称是：" &MyField &"//" &"目标数据是：" &MyTarStr
                End If
	End If
Next
End Function








































































