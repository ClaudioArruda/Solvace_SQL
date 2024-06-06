Jovem Aprendiz
with cteResult (KAIZEN_ID,MENSURABLE,IDEA_KAIZEN,ORIGINATOR_ID,ORIGINATOR_NAME,ORIGINATOR_FULL_NAME,ORIGINATOR_DEPARTMENT,ORIGINATOR_AREA,TEAM,PARTICIPANTS,PARTICIPANTS_FULL_NAME,LOCATION_ID,LOCATION_NAME,EQUIPMENT_NAME,FL_REAPPLICATION,TAGS,AWARD_DEPARTAMENT,AWARD_PLANT,SUBMISSION_DATE,APPROVAL_DATE,FINISHED_DATE,SAVINGS_DELIVERED,APPROVERS,APPROVERS_FULL_NAME,APPROVERS_PENDING,APPROVERS_PENDING_FULL_NAME,MOC_ID,STATUS_ID,STATUS_NAME,TYPE_DESCRIPTION)
as
    (
        select mlh.MELHORIA_ID                 as KAIZEN_ID
              ,mlh.MENSURAVEL                  as MENSURABLE
              ,mlh.TITULO                      as IDEA_KAIZEN
              ,mlh.ORIGINADOR_ID               as ORIGINATOR_ID
              ,ori.USER_FIRST_LAST_NAME        as ORIGINATOR_NAME
              ,ori.USER_FULLNAME               as ORIGINATOR_FULL_NAME
              ,originatorUser.DEPARTMENT_NAME  as ORIGINATOR_DEPARTMENT
              ,originatorUser.AREA_NAME        as ORIGINATOR_AREA
              ,grp.GRUPO_NOME                  as TEAM
              ,(select string_agg(userParticipant.USER_FIRST_LAST_NAME, ', ') within group (order by userParticipant.USER_FIRST_LAST_NAME asc) as [text()] 
                  from dbo.TB_MLH_PARTICIPANTES as tmp with (nolock) inner join dbo.VW_WCM_SITE_USER userParticipant on userParticipant.USER_ID = tmp.PARTICIPANTE_ID where tmp.MELHORIA_ID = mlh.MELHORIA_ID) as PARTICIPANTS

              ,(select string_agg(userParticipant.USER_FULLNAME, ', ') within group (order by userParticipant.USER_FULLNAME asc) as [text()] 
                  from dbo.TB_MLH_PARTICIPANTES as tmp with (nolock) inner join VW_WCM_SITE_USER userParticipant on userParticipant.USER_ID = tmp.PARTICIPANTE_ID where tmp.MELHORIA_ID = mlh.MELHORIA_ID)     as PARTICIPANTS_FULL_NAME

              ,isnull(mlh.LOCALIZACAO_ID, 0)                                                                                                                                            as LOCATION_ID
              ,loc.UDAName                                                                                                                                                              as LOCATION_NAME
              ,eqp.equipamento                                                                                                                                                          as EQUIPMENT_NAME
              ,case when isnull(mlh.REAPLICACAO,0) = 1 then 'Yes' else 'No' end                                                                                                         as FL_REAPPLICATION
              ,(select string_agg(tag.Name, ', ') within group (order by tag.Name asc) as [text()] from DB_MDLZ_PRD_GLOBAL.hashtag.Hashtag as tag with (nolock) 
                        inner join DB_MDLZ_PRD_GLOBAL.hashtag.HashtagRegister                                       as ltag with (nolock) on tag.HashtagId = ltag.HashtagId 
                        inner join VW_WCM_SITE_USER                                                                 as usr  with (nolock) on usr.USER_ID   = mlh.ORIGINADOR_ID 
                where ltag.SiteId = usr.SITE_ID 
                  and ltag.ApplicationId = 'F232DDBA-C1C9-4BE1-9B49-FFDE33E63F1B' 
                  and ltag.RegisterId = mlh.MELHORIA_ID)                                                                                                                                as TAGS
              ,case when isnull(pnt.PREMIO, 0) = 1 then 'X' else '' end                                                                                                                 as AWARD_DEPARTAMENT
              ,case when isnull(pnt.PLANTA, 0) = 1 then 'X' else '' end                                                                                                                 as AWARD_PLANT
              ,mlh.DATA_INC                                                                                                                                                             as SUBMISSION_DATE
              ,mlh.DATA_APROVACAO                                                                                                                                                       as APPROVAL_DATE
              ,mlh.DATA_PONTUACAO                                                                                                                                                       as FINISHED_DATE

              ,case when STATUS_ID < 20 OR STATUS_ID > 30 
                        then '-'
                        else isnull((select isnull(sum(mcc.CUSTO),0) 
                                       from dbo.TB_MLH_MELHORIAS_CATEGORIA_CUSTO as mcc with (nolock) 
                                            inner join TB_MST_CATEGORIA_CUSTO as cc with (nolock) on mcc.CATEGORIA_CUSTO_ID = cc.CATEGORIA_CUSTO_ID    
                                      where mcc.MELHORIA_ID = mlh.MELHORIA_ID),0) 
               end                                                                                                                                  as SAVINGS_DELIVERED
              ,(select string_agg(usrApproval.USER_FIRST_LAST_NAME, ', ') within group (order by usrApproval.USER_FIRST_LAST_NAME asc) as [text()]  
                  from dbo.TB_MLH_LEVEL_WORKFLOW as tmlw with (nolock)
                        inner join VW_WCM_SITE_USER as usrApproval with (nolock) on tmlw.ID_APPROVAL_LEVEL = usrApproval.USER_ID
                 where tmlw.MELHORIA_ID = mlh.MELHORIA_ID
                   and tmlw.FLAG_APPROVAL_LEVEL is not null)                                                                                        as APPROVERS
              ,(select string_agg(usrApproval.USER_FULLNAME, ', ') within group (order by usrApproval.USER_FULLNAME asc) as [text()]  
                  from dbo.TB_MLH_LEVEL_WORKFLOW tmlw with (nolock)
                        inner join VW_WCM_SITE_USER usrApproval on tmlw.ID_APPROVAL_LEVEL = usrApproval.USER_ID
                 where tmlw.MELHORIA_ID = mlh.MELHORIA_ID
                   and tmlw.FLAG_APPROVAL_LEVEL is not null)                                                                                        as APPROVERS_FULL_NAME
              ,(select string_agg(usrApproval.USER_FIRST_LAST_NAME, ', ') within group (order by usrApproval.USER_FIRST_LAST_NAME asc) as [text()]  
                  from dbo.TB_MLH_LEVEL_WORKFLOW as tmlw with (nolock)
                        inner join VW_WCM_SITE_USER usrApproval on tmlw.ID_APPROVAL_LEVEL = usrApproval.USER_ID
                 where tmlw.MELHORIA_ID = mlh.MELHORIA_ID
                   and tmlw.FLAG_APPROVAL_LEVEL is null)                                                                                            as APPROVERS_PENDING
              ,(select string_agg(usrApproval.USER_FULLNAME, ', ') within group (order by usrApproval.USER_FULLNAME asc) as [text()] 
                  from dbo.TB_MLH_LEVEL_WORKFLOW as tmlw with (nolock)
                        inner join VW_WCM_SITE_USER as usrApproval with (nolock) on tmlw.ID_APPROVAL_LEVEL = usrApproval.USER_ID
                 where tmlw.MELHORIA_ID = mlh.MELHORIA_ID
                   and tmlw.FLAG_APPROVAL_LEVEL is null)                                                                                            as APPROVERS_PENDING_FULL_NAME
              ,tmm.ID_MOC                                                                                                                           as MOC_ID
              ,cast(mlh.STATUS as int)                                                                                                              as STATUS_ID
              ,sta.STATUS_NOME                                                                                                                      as STATUS_NAME
              ,replace(replace((select string_agg(tmt.TYPE_NAME, ' , ') within group (order by tmt.TYPE_NAME asc) as [text()] 
                                  from dbo.TB_MLH_MELHORIAS_TYPE as tmmt with (nolock) 
                                        inner join dbo.TB_MLH_TYPE as tmt with (nolock) on tmt.TYPE_ID = tmmt.TYPE_ID 
                                 where MELHORIA_ID = mlh.MELHORIA_ID),'&amp;','&'),'&apos;','`')                                                    as TYPE_DESCRIPTION
          from dbo.TB_MLH_MELHORIAS as mlh with (nolock)
                inner join dbo.TB_MLH_STATUS as sta with (nolock)                   on sta.STATUS_ID          = mlh.STATUS    
                 left join dbo.TB_EMP_EmployeeUnityDepartArea as loc with (nolock)  on mlh.LOCALIZACAO_ID     = loc.idUDA    
                 left join dbo.TB_MLH_MELHORIA_TAG as mtag with (nolock)            on mtag.MELHORIA_ID       = mlh.MELHORIA_ID
                 left join dbo.VW_WCM_SITE_USER    as originatorUser with (nolock)  on originatorUser.USER_ID = mlh.ORIGINADOR_ID
                 left join dbo.TB_MLH_PONTUACAO    as pnt with (nolock)             on pnt.MELHORIA_ID        = mlh.MELHORIA_ID    
                 left join dbo.VW_WCM_SITE_USER    as ori WITH (NOLOCK)             on ori.USER_ID            = mlh.ORIGINADOR_ID
                 left join dbo.TB_SYS_GRUPOS       as grp with (nolock)             on mlh.EQUIPE_ID          = grp.GRUPO_ID
                 left join dbo.TB_MNT_EQUIPAMENTO  as eqp with (nolock)             on eqp.id_equipamento     = mlh.material_id    
                 left join dbo.TB_MOC_MOC          as tmm with (nolock)             on tmm.ID_SOURCE          = mlh.MELHORIA_ID
        group by
            mlh.MELHORIA_ID,
            mlh.MENSURAVEL,
            mlh.TITULO,
            mlh.LOCALIZACAO_ID,
            loc.UDAName,
            mlh.ORIGINADOR_ID,
            ori.USER_FIRST_LAST_NAME,
            ori.USER_FULLNAME,
            mlh.CONTADOR_ACESSO,
            pnt.PREMIO,
            pnt.PLANTA,
            GRUPO_NOME,    
            eqp.equipamento,
            mlh.REAPLICACAO,
            mlh.DATA_APROVACAO,
            mlh.DATA_INC,
            mlh.DATA_PONTUACAO,
            sta.STATUS_ID,
            mlh.STATUS,
            originatorUser.DEPARTMENT_NAME,
            originatorUser.AREA_NAME,
            sta.STATUS_NOME,
            tmm.ID_MOC
    )
    select KAIZEN_ID
          ,MENSURABLE
          ,IDEA_KAIZEN
          ,ORIGINATOR_ID
          ,ORIGINATOR_NAME
          ,ORIGINATOR_FULL_NAME
          ,ORIGINATOR_DEPARTMENT
          ,ORIGINATOR_AREA
          ,TEAM
          ,PARTICIPANTS
          ,PARTICIPANTS_FULL_NAME
          ,LOCATION_ID
          ,LOCATION_NAME
          ,EQUIPMENT_NAME
          ,FL_REAPPLICATION
          ,TAGS
          ,AWARD_DEPARTAMENT
          ,AWARD_PLANT
          ,SUBMISSION_DATE
          ,APPROVAL_DATE
          ,FINISHED_DATE
          ,SAVINGS_DELIVERED
          ,APPROVERS
          ,APPROVERS_FULL_NAME
          ,APPROVERS_PENDING
          ,APPROVERS_PENDING_FULL_NAME
          ,MOC_ID
          ,STATUS_ID
          ,STATUS_NAME
          ,TYPE_DESCRIPTION
    from cteResult
   where 1 = 1 
