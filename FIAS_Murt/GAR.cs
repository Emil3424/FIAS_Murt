//------------------------------------------------------------------------------
// <auto-generated>
//     Этот код создан по шаблону.
//
//     Изменения, вносимые в этот файл вручную, могут привести к непредвиденной работе приложения.
//     Изменения, вносимые в этот файл вручную, будут перезаписаны при повторном создании кода.
// </auto-generated>
//------------------------------------------------------------------------------

namespace FIAS_Murt
{
    using System;
    using System.Collections.Generic;
    
    public partial class GAR
    {
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2214:DoNotCallOverridableMethodsInConstructors")]
        public GAR()
        {
            this.History_adres = new HashSet<History_adres>();
            this.Istor_izmen = new HashSet<Istor_izmen>();
            this.Zayavka = new HashSet<Zayavka>();
            this.Dokuments = new HashSet<Dokuments>();
        }
    
        public int ID_GAR { get; set; }
        public string Mun_otdel { get; set; }
        public string Administr_otdel { get; set; }
        public int IFNSL_FL { get; set; }
        public int IFNSL_YL { get; set; }
        public int OKATO { get; set; }
        public int OKTMO { get; set; }
        public int Pochta_Index { get; set; }
        public int ID_Reestr { get; set; }
        public string Kadastr_nom { get; set; }
        public string Status_zap { get; set; }
        public System.DateTime Data_Vnesenia { get; set; }
        public System.DateTime Data_aktual { get; set; }
    
        public virtual adres_objects adres_objects { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<History_adres> History_adres { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<Istor_izmen> Istor_izmen { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<Zayavka> Zayavka { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<Dokuments> Dokuments { get; set; }
    }
}
