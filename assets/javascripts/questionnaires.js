function show_values_of_natures_box(select)
{var nature = select.value
   var nature_id =  select.id.split('_')[3]
   switch (nature) {
    case "YES_NO":
      $('questionnaire_questions_attributes_' + nature_id + '_nature_values').setValue(''); $('questionnaire_questions_attributes_' + nature_id + '_nature_values').hide();
    case "FREE_TEXT":
      $('questionnaire_questions_attributes_' + nature_id + '_nature_values').setValue(''); $('questionnaire_questions_attributes_' + nature_id + '_nature_values').hide();
      break;
    case "UNIQUE_CHOICE_LIST":
      $('questionnaire_questions_attributes_' + nature_id + '_nature_values').show();
      $('questionnaire_questions_attributes_' + nature_id + '_nature_values').focus();
      break;
    case "MULTI_CHOICE_LIST":
      $('questionnaire_questions_attributes_' + nature_id + '_nature_values').show();
      $('questionnaire_questions_attributes_' + nature_id + '_nature_values').focus();
      break;
    default:
      $('questionnaire_questions_attributes_' + nature_id + '_nature_values').hide();
      break;
   }
}

function remove_question_fields(link)
{$(link).previous("input[type=hidden]").value = "1";
  $(link).up("tr").hide();
}

function add_question_fields(content) {
  var new_id = new Date().getTime();
  var regexp = new RegExp("new_question", "g")
  $("questions").insert({bottom: content.replace(regexp, new_id)});
  $('questionnaire_questions_attributes_' + new_id + '_nature_values').hide();
  $('questionnaire_questions_attributes_' + new_id + '_entitled').focus();
}

function hideAllNatureValuesBox()
{var rows = $$("tbody tr");
  for (var i = 0; i < rows.length; i++)
      {
       if ($('questionnaire_questions_attributes_' + i + '_nature').value == 'YES_NO' || $('questionnaire_questions_attributes_' + i + '_nature').value == 'FREE_TEXT')
           {$('questionnaire_questions_attributes_' + i + '_nature_values').hide();
               $('questionnaire_questions_attributes_' + i + '_nature_values').setValue('');
           }
      }
}

function canBePublished(message)
{ if (($('questionnaire_validate_by')) && ($('questionnaire_validate_by').value != ""))
  { if ($('questionnaire_published').checked) alert(message);
    $('questionnaire_published').checked = false;
  }
}


function getrecipients()
{ var recipients = new Array();
  var r = $$("#myrecipients_chzn a");
  for(var i = 0; i < r.length; i++) { recipients[i] = r[i].rel; }

}

 function selectAll(check, checksclass){
    $$(checksclass).each(function(e){
      check.checked ? $(e).checked = true : $(e).checked = false;
    });
}
