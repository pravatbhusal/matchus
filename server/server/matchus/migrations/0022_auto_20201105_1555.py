# Generated by Django 3.1.2 on 2020-11-05 15:55

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('matchus', '0021_auto_20201105_1554'),
    ]

    operations = [
        migrations.AlterField(
            model_name='user',
            name='profile_photo',
            field=models.ImageField(upload_to='media/'),
        ),
    ]